package com.xinguoedu.consts
{
	public class GroupStatus
	{
		public function GroupStatus()
		{
		}
		
		/**
		 * NetGroup 已构建成功并有权使用函数 
		 */		
		public static const SUCCESS:String = 'NetGroup.Connect.Success';
		
		/**
		 * NetGroup 连接尝试失败 
		 */		
		public static const FAILED:String = 'NetGroup.Connect.Failed';	
		
		/**
		 * 当收到新的 Group Posting 时发送 
		 */		
		public static const POSTING_NOTIFY:String = 'NetGroup.Posting.Notify';
			
		/**
		 * 当在 NetGroup 的组中检测到新命名的流时发送
		 */		
		public static const PUBLISH_NOTIFY:String = 'NetGroup.MulticastStream.PublishNotify';
			
		/**
		 * 当命名的流在此组中不再可用时发送
		 */		
		public static const UNPUBLISH_NOTIFY:String = 'NetGroup.MulticastStream.UnpublishNotify';	
	}
}