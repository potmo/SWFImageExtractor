package com.potmo.imagextractor
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class AliasRasterizedFrame implements RasterizedFrame
	{
		private var _frame:int;
		private var _label:String;
		private var _rect:Rectangle;
		private var _regpoint:Point;
		private var _name:String;
		private var _originalBounds:Rectangle;
		private var _offset:Point;


		public function AliasRasterizedFrame()
		{
		}


		public function getFrame():int
		{
			return _frame;
		}


		public function setFrame( frame:int ):void
		{
			_frame = frame;
		}


		public function getLabel():String
		{
			return _label;
		}


		public function setLabel( label:String ):void
		{
			_label = label;
		}


		public function getTextureSourceRect():Rectangle
		{
			return _rect;
		}


		public function setTextureSourceRect( rect:Rectangle ):void
		{
			_rect = rect;
		}


		public function getRegpoint():Point
		{
			return _regpoint;
		}


		public function setRegpoint( point:Point ):void
		{
			_regpoint = point;
		}


		public function getName():String
		{
			return _name;
		}


		public function setName( name:String ):void
		{
			_name = name;
		}


		public function getSpriteBounds():Rectangle
		{
			return _originalBounds;
		}


		public function setSpriteBounds( originalBounds:Rectangle ):void
		{
			_originalBounds = originalBounds;
		}


		public function getTextureInSpriteOffset():Point
		{
			return _offset;
		}


		public function setTextureInSpriteOffset( offset:Point ):void
		{
			_offset = offset;
		}


		public function getImage():BitmapData
		{
			throw new Error( "This is an alias" );
		}


		public function setImage( image:BitmapData ):void
		{
			throw new Error( "This is an alias" )
		}


		public function isAlias():Boolean
		{
			return true;
		}


		public function getXML():XML
		{
			//TODO: Implement me
			throw new Error( "Implement me" );
		}

	}
}
