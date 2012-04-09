package com.potmo.imagextractor
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class RealRasterizedFrame implements RasterizedFrame
	{
		private var _frame:int = -1;
		private var _label:String = "";
		private var _rect:Rectangle = null;
		private var _regpoint:Point = null;
		private var _name:String = "";
		private var _image:BitmapData;
		private var _originalBounds:Rectangle;
		private var _offset:Point;


		public function RealRasterizedFrame()
		{
		}


		public function getImage():BitmapData
		{
			return _image;
		}


		public function setImage( value:BitmapData ):void
		{
			_image = value;
		}


		public function getName():String
		{
			return _name;
		}


		public function setName( value:String ):void
		{
			_name = value;
		}


		public function getRegpoint():Point
		{
			return _regpoint;
		}


		public function setRegpoint( value:Point ):void
		{
			_regpoint = value;
		}


		public function getTextureSourceRect():Rectangle
		{
			return _rect;
		}


		public function setTextureSourceRect( value:Rectangle ):void
		{
			_rect = value;
		}


		public function getLabel():String
		{
			return _label;
		}


		public function setLabel( value:String ):void
		{
			_label = value;
		}


		public function getFrame():int
		{
			return _frame;
		}


		public function setFrame( value:int ):void
		{
			_frame = value;
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


		public function isAlias():Boolean
		{
			return false;
		}


		public function getXML():XML
		{
			return <frame>
					<name>{_name}</name>
					<number>{_frame}</number>
					<label>{_label}</label>
					<regpointx>{_regpoint.x}</regpointx>
					<regpointy>{_regpoint.y}</regpointy>
					<texturex>{_rect.x}</texturex>
					<texturey>{_rect.y}</texturey>
					<texturewidth>{_rect.width}</texturewidth>
					<textureheight>{_rect.height}</textureheight>
					<offsetx>{_offset.x}</offsetx>
					<offsety>{_offset.y}</offsety>
				</frame>;
		}


		public function toString():String
		{
			return "{name:" + _name + ", label:" + _label + ", frame: " + _frame + ", width:" + _rect.width + ", height: " + _rect.height + ", regpoint:" + _regpoint + ", offset: " + _offset + "}"
		}

	}
}
