package org.openpyro.plugins.airHelpers.db{
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	import net.comcast.logging.Logger;
	
	public class Base{
		
		private var _dbFile:File;
		
		public function Base(file:File){
			initializeDatabase(file);
		}
		
		protected var sqlConnection:SQLConnection;
		
		protected function initializeDatabase(file:File):void{
			sqlConnection = new SQLConnection();
			_dbFile = file;
			if(this._dbFile.exists){
				sqlConnection.addEventListener(SQLEvent.OPEN, onDBOpen);
			}
			else{
				sqlConnection.addEventListener(SQLEvent.OPEN, setupDatabase);
			}
			sqlConnection.addEventListener(SQLErrorEvent.ERROR, onSQLConnectionError);
			sqlConnection.open(_dbFile);
		}
		
		protected var currentlyExecutingStatement:SQLStatement;
		protected function executeSQL(sql:String, responder:Function=null):void{
			try{
				
				if(currentlyExecutingStatement && currentlyExecutingStatement.executing){
					currentlyExecutingStatement.cancel()
				}
				
				currentlyExecutingStatement = new SQLStatement();
				currentlyExecutingStatement.sqlConnection = sqlConnection;
				if(responder != null){
					currentlyExecutingStatement.addEventListener(SQLEvent.RESULT, responder);
				}
				currentlyExecutingStatement.text = sql;
				currentlyExecutingStatement.execute();
			}catch(e:SQLError){
				Logger.error(this, "Error executing sql: "+e.message+"["+e.errorID+"] ");
				return;
			}
		}
		
		protected function setupDatabase(event:SQLEvent):void{
				
		}
		
		protected function onDBOpen(event:SQLEvent):void{
			
		}
		
		private function onSQLConnectionError(event:SQLErrorEvent):void{
			Logger.error(this, "Error using History Database");
		}

	}
}