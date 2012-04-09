package com.potmo.imagextractor
{
	import flash.display.BitmapData;

	public class PacketFrames
	{
		private var _xml:XML;
		private var _image:BitmapData;


		public function PacketFrames( image:BitmapData, xml:XML )
		{
			_xml = xml;
			_image = image;
		}


		public function getXML():XML
		{
			return _xml;
		}


		public function getImage():BitmapData
		{
			return _image;
		}
	}
}
