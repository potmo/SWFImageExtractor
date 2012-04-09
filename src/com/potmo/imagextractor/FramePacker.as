package com.potmo.imagextractor
{
	import com.potmo.util.image.BitmapUtil;
	import com.potmo.util.logger.Logger;
	import com.potmo.util.math.StrictMath;
	import com.potmo.util.packing.MaxRectBinPacker;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class FramePacker
	{
		private var _packer:MaxRectBinPacker;
		private var _rasterizer:Rasterizer;

		private static const MAX_WIDTH:int = 2048;
		private static const MAX_HEIGHT:int = 2048;
		private static const PADDING:int = 2;


		public function FramePacker()
		{
			_packer = new MaxRectBinPacker( MAX_WIDTH, MAX_HEIGHT );
			_rasterizer = new Rasterizer();
		}


		public function rasterizeAndPack( displayObjects:Vector.<DisplayObject> ):PacketFrames
		{
			Logger.info( "Starting to rasterize: " + displayObjects.length + " objects" );
			var frames:Vector.<RasterizedFrame> = _rasterizer.rasterize( displayObjects );

			frames = trimTransparent( frames, PADDING );

			//TODO: Remove duplicate images and make them aliases

			var image:BitmapData = pack( frames, PADDING );
			var xml:XML = getDescriptorXml( frames );

			var packetFrames:PacketFrames = new PacketFrames( image, xml );

			return packetFrames;

		}


		private function trimTransparent( frames:Vector.<RasterizedFrame>, padding:int ):Vector.<RasterizedFrame>
		{

			for each ( var frame:RasterizedFrame in frames )
			{
				var image:BitmapData = frame.getImage();

				// trim transparent pixels
				var bounds:Rectangle = image.getColorBoundsRect( 0xFF000000, 0x00000000, false );
				var output:BitmapData = new BitmapData( bounds.width, bounds.height, true );
				output.copyPixels( image, bounds, new Point( 0, 0 ) );
				frame.setImage( output );

				var rect:Rectangle = frame.getTextureSourceRect();
				rect.width = output.width + padding * 2;
				rect.height = output.height + padding * 2;
				frame.setTextureSourceRect( rect );

				// add some padding
				frame.setTextureInSpriteOffset( new Point( rect.x + padding, rect.y + padding ) );

			}
			return frames;
		}


		private function getDescriptorXml( frames:Vector.<RasterizedFrame> ):XML
		{
			var xml:XML = XML( "<?xml version=\"1.0\" encoding=\"UTF-8\"?><atlas></atlas>" );
			xml.appendChild( <metadata></metadata> );
			xml.metadata.appendChild( <date>{getDateString()}</date> );
			xml.metadata.appendChild( <padding>{PADDING}</padding> );
			xml.appendChild( <frames></frames> );

			for each ( var frame:RasterizedFrame in frames )
			{
				xml[ "frames" ][ 0 ].appendChild( frame.getXML() );
			}

			Logger.info( "XML:\n" + xml.toXMLString() );
			return xml;

		}


		private function pack( frames:Vector.<RasterizedFrame>, padding:int ):BitmapData
		{
			frames.sort( frameSizeComparator );

			_packer.allowFlip = false;
			_packer.addEventListener( Event.COMPLETE, onCompletePacking );
			Logger.info( "Starting to pack: " + frames.length + " frames" );

			var frame:RasterizedFrame;

			// pack images
			for each ( frame in frames )
			{
				// do not print any frames that are aliases
				if ( frame.isAlias() )
				{
					continue;
				}

				// insert into packer
				var newPosition:Rectangle = _packer.insert( frame.getTextureSourceRect().width, frame.getTextureSourceRect().height, MaxRectBinPacker.METHOD_RECT_BEST_AREA_FIT );

				frame.setTextureSourceRect( newPosition );

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
			var image:BitmapData = new BitmapData( totalCanvasRect.width, totalCanvasRect.height, true, 0xFFCCCCCC );

			for each ( frame in frames )
			{
				// do not print any frames that are aliases
				if ( frame.isAlias() )
				{
					continue;
				}
				// the image is smaller than the texture source rect so add padding
				BitmapUtil.blit( image, frame.getImage(), frame.getTextureSourceRect().x + padding, frame.getTextureSourceRect().y + padding );
				BitmapUtil.drawRectangle( frame.getTextureSourceRect().x + padding, frame.getTextureSourceRect().y + padding, frame.getTextureSourceRect().width - padding * 2, frame.getTextureSourceRect().height - padding * 2, 0xFFFF0000, image );
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


		private function onCompletePacking( event:Event ):void
		{
			Logger.info( "Complete packing" );
		}
	}
}
