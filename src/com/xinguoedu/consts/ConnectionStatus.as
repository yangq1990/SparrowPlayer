package com.xinguoedu.consts
{
	/**
	 * 连接状态 
	 * @author yangq1990
	 * 
	 */	
	public class ConnectionStatus
	{
		/**
		 * 连接尝试成功 
		 */		
		public static const SUCCESS:String = "NetConnection.Connect.Success";
		
		/**
		 * 连接尝试失败 
		 */		
		public static const FAILED:String = "NetConnection.Connect.Failed";
		
		/**
		 * 成功关闭连接
		 */		
		public static const CLOSED:String = "NetConnection.Connect.Closed";
		
		/**
		 * 连接尝试没有访问应用程序的权限
		 */		
		public static const REJECTED:String = "NetConnection.Connect.Rejected";
		
		/**
		 * 连接media server sercurity error 
		 */		
		public static const SECURITY_ERROR:String = "securityerror";
		
		
	}
}