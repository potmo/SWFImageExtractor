package com.potmo.imagextractor
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public interface RasterizedFrame
	{

		function getFrame():int;
		function setFrame( frame:int ):void;
		function getLabel():String;
		function setLabel( label:String ):void;
		function getTextureSourceRect():Rectangle;
		function setTextureSourceRect( rect:Rectangle ):void;
		function getSpriteBounds():Rectangle;
		function setSpriteBounds( originalBounds:Rectangle ):void;
		function getRegpoint():Point; // in sprite bounds
		function setRegpoint( point:Point ):void;
		function getName():String;
		function setName( name:String ):void;
		function getImage():BitmapData;
		function setImage( image:BitmapData ):void;
		function getTextureInSpriteOffset():Point;
		function setTextureInSpriteOffset( offset:Point ):void;

		function isAlias():Boolean;

		function getXML():XML;
	}
}
