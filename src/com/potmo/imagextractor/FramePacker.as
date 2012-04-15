package com.potmo.imagextractor
{
	import com.potmo.util.image.BitmapUtil;
	import com.potmo.util.logger.Logger;
	import com.potmo.util.math.StrictMath;
	import com.potmo.util.packing.MaxRectBinPacker;
	import com.potmo.util.packing.PackRectangle;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class FramePacker
	{
		private var _rasterizer:Rasterizer;

		private static const MAX_WIDTH:int = 2048;
		private static const MAX_HEIGHT:int = 2048;
		private static const PADDING:int = 1;


		public function FramePacker()
		{

			_rasterizer = new Rasterizer();
		}


		public function rasterizeAndPack( displayObjects:Vector.<DisplayObject> ):PacketFrames
		{
			Logger.info( "Starting to rasterize: " + displayObjects.length + " objects" );
			var frames:Vector.<RasterizedFrame>;

			frames = _rasterizer.rasterize( displayObjects );

			frames = trimTransparent( frames, PADDING );

			frames = removeDuplicates( frames );

			var image:BitmapData = pack( frames, PADDING );
			var xml:XML = getDescriptorXml( frames );

			var packetFrames:PacketFrames = new PacketFrames( image, xml );

			return packetFrames;

		}


		private function removeDuplicates( frames:Vector.<RasterizedFrame> ):Vector.<RasterizedFrame>
		{

			frames = frames.concat(); // clone
			var output:Vector.<RasterizedFrame> = new Vector.<RasterizedFrame>();

			//find all like
			while ( frames.length > 0 )
			{

				// get a item that is not a duplicate
				var original:RasterizedFrame = frames[ 0 ];

				Logger.info( "Adding real frame : " + original );

				// add the frame to output
				output.push( original );
				// remove
				frames.splice( 0, 1 );

				// frames that are already alias can be skipped (should not be any but anyway)
				if ( original.isAlias() )
				{
					continue;
				}

				// check for equality with all other frames
				var originalImage:BitmapData = original.getImage();

				var potentialDuplicateImage:BitmapData;
				var potentialDuplicate:RasterizedFrame;

				for ( var j:int = frames.length - 1; j >= 0; j-- )
				{
					potentialDuplicate = frames[ j ];
					potentialDuplicateImage = potentialDuplicate.getImage();

					// oddly the compare function returns a zero if
					// both images is identical in both width, height and pixels
					if ( originalImage.compare( potentialDuplicateImage ) == 0 )
					{
						//Logger.info( "Found duplicate: " + original + " is equal to " + potentialDuplicate );

						// remove from frames
						frames.splice( j, 1 );

						// remove from frames
						var frameToBeAlias:RasterizedFrame = potentialDuplicate;
						var frameThatShouldBeAliased:RasterizedFrame = original;

						// create a alias and add the new aliased frame
						var alias:RasterizedFrame = RasterizedFrame.createAlias( frameToBeAlias, frameThatShouldBeAliased );
						Logger.info( "Adding alias frame: " + alias );
						output.push( alias );
					}
				}

			}

			return output;

		}


		private function trimTransparent( frames:Vector.<RasterizedFrame>, padding:int ):Vector.<RasterizedFrame>
		{

			for each ( var frame:RasterizedFrame in frames )
			{
				var image:BitmapData = frame.getImage();

				// trim transparent pixels
				var bounds:Rectangle = image.getColorBoundsRect( 0xFF000000, 0x00000000, false );
				var output:BitmapData = new BitmapData( bounds.width + padding * 2, bounds.height + padding * 2, true, 0x00000000 );
				output.copyPixels( image, bounds, new Point( padding, padding ) );
				frame.setImage( output );

				// add some padding
				var rect:Rectangle = frame.getTextureSourceRect();
				rect.width = output.width;
				rect.height = output.height;
				rect.x -= padding; // this does'nt really matter since it will be moved when packed
				rect.y -= padding;
				frame.setTextureSourceRect( rect );

				// set texture in sprite offset
				frame.setTextureInSpriteOffset( new Point( bounds.x - padding + 1, bounds.y - padding + 1 ) );

			}
			return frames;
		}


		private function getDescriptorXml( frames:Vector.<RasterizedFrame> ):XML
		{
			var xml:XML = XML( "<atlas></atlas>" );
			xml.appendChild( <metadata></metadata> );
			xml.metadata.appendChild( <date>{getDateString()}</date> );
			xml.metadata.appendChild( <padding>{PADDING}</padding> );
			xml.appendChild( <frames></frames> );

			for each ( var frame:RasterizedFrame in frames )
			{
				xml[ "frames" ][ 0 ].appendChild( frame.getXML() );
			}

			//Logger.info( "XML:\n" + xml.toXMLString() );
			return xml;

		}


		private function pack( frames:Vector.<RasterizedFrame>, padding:int ):BitmapData
		{
			frames.sort( frameSizeComparator );

			var packer:MaxRectBinPacker = new MaxRectBinPacker( MAX_WIDTH, MAX_HEIGHT );
			packer.allowFlip = false;

			Logger.info( "Starting to pack: " + frames.length + " frames" );

			var frame:RasterizedFrame;

			// get rects to pack
			var packRects:Vector.<PackRectangle> = new Vector.<PackRectangle>();

			for ( var i:int = 0; i < frames.length; i++ )
			{
				// do not print any frames that are aliases
				frame = frames[ i ];

				if ( frame.isAlias() )
				{
					continue;
				}

				// insert into packer
				var packRect:PackRectangle = PackRectangle.fromRegularRectangle( frame.getTextureSourceRect(), i );
				packRects.push( packRect );

			}

			var packedRects:Vector.<PackRectangle> = packer.insertMany( packRects, MaxRectBinPacker.METHOD_RECT_BEST_AREA_FIT );

			for each ( var packedRect:PackRectangle in packedRects )
			{
				frame = frames[ packedRect.getId() ];
				frame.setTextureSourceRect( packedRect.toRegularRectangle() );
			}

			// update aliases from originals
			for each ( frame in frames )
			{
				if ( frame.isAlias() )
				{
					frame.updateFromAliasSource();
				}
			}

			// find the smallest frame to put them in
			var totalCanvasRect:Rectangle = new Rectangle();

			for each ( frame in frames )
			{
				// do not print any frames that are aliases
				if ( frame.isAlias() )
				{
					continue;
				}

				totalCanvasRect = totalCanvasRect.union( frame.getTextureSourceRect() );

			}

			// make frame width and height be a power of two
			totalCanvasRect.width = StrictMath.getNextPowerOfTwo( totalCanvasRect.width );
			totalCanvasRect.height = StrictMath.getNextPowerOfTwo( totalCanvasRect.height );

			// blit to canvas
			var image:BitmapData = new BitmapData( totalCanvasRect.width, totalCanvasRect.height, true, 0x00000000 );

			for each ( frame in frames )
			{
				// do not print any frames that are aliases
				if ( frame.isAlias() )
				{

					continue;
				}
				// the image is smaller than the texture source rect so add padding
				BitmapUtil.blit( image, frame.getImage(), frame.getTextureSourceRect().x, frame.getTextureSourceRect().y );

					// draw bounds for debugging
					//	BitmapUtil.drawRectangle( frame.getTextureSourceRect().x, frame.getTextureSourceRect().y, frame.getTextureSourceRect().width, frame.getTextureSourceRect().height, 0x66FF0000, image );

					// draw regpoint for debugging
				/*var regpoint:Point = frame.getRegpoint().clone();
				   var offset:Point = frame.getTextureInSpriteOffset();
				   regpoint.x -= offset.x;
				   regpoint.y -= offset.y;
				   BitmapUtil.drawRectangle( frame.getTextureSourceRect().x + regpoint.x - 1, frame.getTextureSourceRect().y + regpoint.y - 1, 3, 3, 0x6600FF00, image );
				 */
			}

			return image;
		}


		private function frameSizeComparator( a:RasterizedFrame, b:RasterizedFrame ):int
		{
			var aArea:Number = a.getTextureSourceRect().width * a.getTextureSourceRect().height;
			var bArea:Number = b.getTextureSourceRect().width * b.getTextureSourceRect().height;

			if ( aArea == bArea )
			{
				return 0;
			}
			return aArea < bArea ? 1 : -1;

		}


		private function getDateString():String
		{
			var date:Date = new Date();
			return date.fullYearUTC + "-" + date.monthUTC + "-" + date.dateUTC + " " + date.hoursUTC + ":" + date.minutesUTC + ":" + date.secondsUTC + ":" + date.millisecondsUTC;

		}

	}
}
