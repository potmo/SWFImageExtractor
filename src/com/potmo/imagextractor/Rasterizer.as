package com.potmo.imagextractor
{
	import com.potmo.util.image.BitmapUtil;
	import com.potmo.util.logger.Logger;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Rasterizer
	{
		public function Rasterizer()
		{
		}


		public function rasterize( displayObjects:Vector.<DisplayObject> ):Vector.<RasterizedFrame>
		{
			var allFrames:Vector.<RasterizedFrame> = new Vector.<RasterizedFrame>();
			var frames:Vector.<RasterizedFrame>;

			for each ( var displayObject:DisplayObject in displayObjects )
			{
				frames = rasterizeClip( displayObject );

				for each ( var frame:RasterizedFrame in frames )
				{
					Logger.info( "Adding: " + frame );
					allFrames.push( frame );
				}
			}

			return allFrames;
		}


		private function rasterizeClip( displayObject:DisplayObject ):Vector.<RasterizedFrame>
		{
			var allFrames:Vector.<RasterizedFrame> = new Vector.<RasterizedFrame>();

			if ( displayObject is MovieClip )
			{
				var frames:Vector.<RasterizedFrame> = createFramesFromMovieClip( displayObject as MovieClip );

				for each ( var sub:RasterizedFrame in frames )
				{
					allFrames.push( sub );
				}
			}
			else
			{

				var frame:RasterizedFrame = createFrameFromDisplayObject( displayObject );
				allFrames.push( frame );
			}

			return allFrames;
		}


		private function createFrameFromDisplayObject( displayObject:DisplayObject ):RasterizedFrame
		{

			var bounds:Rectangle = bounds = displayObject.getBounds( displayObject );
			var image:BitmapData = BitmapUtil.rasterizeDisplayObject( displayObject, bounds );

			var frame:RasterizedFrame = new RasterizedFrame();
			frame.setAlias( false );
			frame.setFrame( 0 );
			frame.setLabel( "" );
			frame.setName( displayObject.name );
			frame.setRegpoint( new Point( -bounds.x, -bounds.y ) );
			frame.setTextureSourceRect( new Rectangle( 0, 0, bounds.width, bounds.height ) );
			frame.setImage( image );
			frame.setSpriteBounds( new Rectangle( 0, 0, bounds.width, bounds.height ) );

			return frame;
		}


		private function createFramesFromMovieClip( clip:MovieClip ):Vector.<RasterizedFrame>
		{
			var out:Vector.<RasterizedFrame> = new Vector.<RasterizedFrame>();

			var bounds:Rectangle = BitmapUtil.getEnclosingRect( clip );

			var frames:int = clip.totalFrames;
			var frameNum:int = frames + 1;

			var labels:Array = clip.currentLabels;

			while ( --frameNum >= 1 )
			{
				clip.gotoAndStop( frameNum );

				var image:BitmapData = BitmapUtil.rasterizeDisplayObject( clip, bounds );
				var frame:RasterizedFrame = new RasterizedFrame();
				frame.setAlias( false );
				frame.setFrame( frameNum - 1 );
				frame.setName( clip.name )
				frame.setRegpoint( new Point( -bounds.x, -bounds.y ) );
				frame.setTextureSourceRect( new Rectangle( 0, 0, bounds.width, bounds.height ) );
				frame.setSpriteBounds( new Rectangle( 0, 0, bounds.width, bounds.height ) );
				frame.setLabel( "" );
				frame.setImage( image );
				var label:String = findLabelForFrame( frameNum, labels );
				frame.setLabel( label );

				out.push( frame );
			}

			return out;
		}


		private function findLabelForFrame( frame:int, labels:Array /*of FrameLabel*/ ):String
		{
			for each ( var label:FrameLabel in labels )
			{
				if ( label.frame == frame )
				{
					return label.name;
				}
			}

			return "";
		}

	}

}
