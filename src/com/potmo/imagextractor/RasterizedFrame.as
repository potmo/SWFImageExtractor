package com.potmo.imagextractor
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class RasterizedFrame
	{
		private var _frame:int = -1;
		private var _label:String = "";
		private var _textureSourceRect:Rectangle = null;
		private var _regpoint:Point = null;
		private var _name:String = "";
		private var _image:BitmapData;
		private var _spriteBounds:Rectangle;
		private var _textureInSpriteOffset:Point;
		private var _alias:Boolean;


		public function RasterizedFrame()
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
			return _textureSourceRect;
		}


		public function setTextureSourceRect( value:Rectangle ):void
		{
			_textureSourceRect = value;
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
			return _spriteBounds;
		}


		public function setSpriteBounds( originalBounds:Rectangle ):void
		{
			_spriteBounds = originalBounds;
		}


		public function getTextureInSpriteOffset():Point
		{
			return _textureInSpriteOffset;
		}


		public function setTextureInSpriteOffset( offset:Point ):void
		{
			_textureInSpriteOffset = offset;
		}


		public function isAlias():Boolean
		{
			return _alias;
		}


		public function setAlias( alias:Boolean ):void
		{
			_alias = alias;
		}


		public function getXML():XML
		{
			return <frame>
					<name>{_name}</name>
					<number>{_frame}</number>
					<label>{_label}</label>
					<regpointx>{_regpoint.x}</regpointx>
					<regpointy>{_regpoint.y}</regpointy>
					<texturex>{_textureSourceRect.x}</texturex>
					<texturey>{_textureSourceRect.y}</texturey>
					<texturewidth>{_textureSourceRect.width}</texturewidth>
					<textureheight>{_textureSourceRect.height}</textureheight>
					<offsetx>{_textureInSpriteOffset.x}</offsetx>
					<offsety>{_textureInSpriteOffset.y}</offsety>
					<spritewidth>{_spriteBounds.width}</spritewidth>
					<spriteheight>{_spriteBounds.height}</spriteheight>
					<isalias>{_alias}</isalias>
				</frame>;
		}


		public function toString():String
		{
			//return "{name:" + _name + ", label:" + _label + ", frame: " + _frame + ", width:" + _textureSourceRect.width + ", height: " + _textureSourceRect.height + ", regpoint:" + _regpoint + ", offset: " + _textureInSpriteOffset + "}"
			return "{name: " + _name + ", frame:" + _frame + "}";
		}


		public static function createAlias( frameToBeAlias:RasterizedFrame, frameThatShouldBeAliased:RasterizedFrame ):RasterizedFrame
		{
			var alias:RasterizedFrame = new RasterizedFrame();
			alias.setAlias( true );
			alias.setFrame( frameToBeAlias.getFrame() );
			// skip image
			alias.setLabel( frameToBeAlias.getLabel() );
			alias.setName( frameToBeAlias.getName() );
			alias.setRegpoint( frameToBeAlias.getRegpoint().clone() );
			alias.setSpriteBounds( frameToBeAlias.getSpriteBounds().clone() );
			var aliasOffset:Point = frameToBeAlias.getTextureInSpriteOffset().clone();
			var offset:Point = frameThatShouldBeAliased.getTextureInSpriteOffset().clone();

			aliasOffset.x = aliasOffset.x - offset.x + aliasOffset.x;
			aliasOffset.y = aliasOffset.y - offset.y + aliasOffset.y;

			alias.setTextureInSpriteOffset( aliasOffset );
			alias.setTextureSourceRect( frameThatShouldBeAliased.getTextureSourceRect() ); // do not clone this one
			return alias;
		}

	}
}
