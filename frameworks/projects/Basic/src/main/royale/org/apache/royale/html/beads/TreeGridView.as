////////////////////////////////////////////////////////////////////////////////
//
//  Licensed to the Apache Software Foundation (ASF) under one or more
//  contributor license agreements.  See the NOTICE file distributed with
//  this work for additional information regarding copyright ownership.
//  The ASF licenses this file to You under the Apache License, Version 2.0
//  (the "License"); you may not use this file except in compliance with
//  the License.  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
////////////////////////////////////////////////////////////////////////////////
package org.apache.royale.html.beads
{
	import org.apache.royale.core.IBeadLayout;
	import org.apache.royale.core.IBeadModel;
	import org.apache.royale.core.IBeadView;
	import org.apache.royale.core.IDataGridModel;
	import org.apache.royale.core.IDataGridPresentationModel;
	import org.apache.royale.core.ISelectionModel;
	import org.apache.royale.core.IStrand;
	import org.apache.royale.core.IUIBase;
	import org.apache.royale.core.UIBase;
	import org.apache.royale.core.ValuesManager;
	import org.apache.royale.events.Event;
	import org.apache.royale.events.IEventDispatcher;
	import org.apache.royale.html.Container;
	import org.apache.royale.html.DataGridButtonBar;
	import org.apache.royale.html.List;
	import org.apache.royale.html.Tree;
	import org.apache.royale.html.TreeGrid;
	import org.apache.royale.html.beads.IDataGridView;
	import org.apache.royale.html.beads.layouts.ButtonBarLayout;
	import org.apache.royale.html.beads.layouts.TreeGridLayout;
	import org.apache.royale.html.beads.models.ButtonBarModel;
	import org.apache.royale.html.beads.models.SingleSelectionCollectionViewModel;
	import org.apache.royale.html.supportClasses.DataGridColumn;
	import org.apache.royale.html.supportClasses.IDataGridColumn;
	import org.apache.royale.html.supportClasses.TreeGridColumn;
	import org.apache.royale.html.supportClasses.Viewport;
	
	/**
	 * The TreeGridView class is responsible for creating the sub-components of the TreeGrid:
	 * the ButtonBar header, the Tree (first column), and Lists (rest of the columns), as well
	 * as the container that holds the columns. This bead will also add in a TreeGridLayout
	 * if one has not already been created or specified in CSS.
	 * 
	 *  @langversion 3.0
	 *  @playerversion Flash 10.2
	 *  @playerversion AIR 2.6
	 *  @productversion Royale 0.9
	 */
	public class TreeGridView extends GroupView implements IBeadView, IDataGridView
	{
		/**
		 * Constructor.
		 * 
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9
		 */
		public function TreeGridView()
		{
			super();
		}
		
		private var _strand:IStrand;
		private var _header:DataGridButtonBar;
		private var _listArea:Container;
		
		private var _lists:Array;
		
		/**
		 * An array of List objects the comprise the columns of the DataGrid.
		 */
		public function get columnLists():Array
		{
			return _lists;
		}
		
		/**
		 * The area used to hold the columns
		 *
		 */
		public function get listArea():Container
		{
			return _listArea;
		}
		
		/**
		 * Returns the component used as the header for the DataGrid.
		 */
		public function get header():IUIBase
		{
			return _header;
		}
		
		/**
		 *  @copy org.apache.royale.core.IBead#strand
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.0
		 */
		override public function set strand(value:IStrand):void
		{
			super.strand = value;
			_strand = value;
			
			var layout:IBeadLayout = _strand.getBeadByType(TreeGridLayout) as IBeadLayout;
			if (layout == null) {
				var layoutClass:Class = ValuesManager.valuesImpl.getValue(_strand, "iBeadLayout") as Class;
				if (layoutClass != null) {
					layout = new layoutClass() as IBeadLayout;
				} else {
					layout = new TreeGridLayout(); // default
				}
				_strand.addBead(layout);
			}

			IEventDispatcher(_strand).addEventListener("beadsAdded", finishSetup);
		}
		
		public function refreshContent():void
		{
			finishSetup(null);
		}
		
		/**
		 * @private
		 */
		protected function finishSetup(event:Event):void
		{
			var host:TreeGrid = _strand as TreeGrid;
			
			// see if there is a presentation model already in place. if not, add one.
			var presentationModel:IDataGridPresentationModel = host.presentationModel;
			var sharedModel:IDataGridModel = host.model as IDataGridModel;
			IEventDispatcher(sharedModel).addEventListener("dataProviderChanged",handleDataProviderChanged);
			IEventDispatcher(sharedModel).addEventListener("selectedIndexChanged", handleSelectedIndexChanged);
			
			_header = new DataGridButtonBar();
			// header's height is set in CSS
			_header.percentWidth = 100;
			_header.dataProvider = sharedModel.columns;
			_header.labelField = "label";
			sharedModel.headerModel = _header.model as IBeadModel;
			
			_listArea = new Container();
			_listArea.percentWidth = 100;
			_listArea.className = "opt_org-apache.royale-html-TreeGrid_ListArea";
				
			createColumns();
			
			var buttonWidths:Array = [];
			
			var marginBorderOffset:int = 0;
			COMPILE::SWF {
				marginBorderOffset = 1;
			}
				
			for(var i:int=0; i < sharedModel.columns.length; i++) {
				var dgc:DataGridColumn = sharedModel.columns[i] as DataGridColumn;
				var colWidth:Number = dgc.columnWidth - marginBorderOffset;
				buttonWidths.push(colWidth);
				
				var list:UIBase = _lists[i] as UIBase;
				if (!isNaN(colWidth)) {
					list.width = Number(colWidth - marginBorderOffset);
				}
			}
				
			var bblayout:ButtonBarLayout = new ButtonBarLayout();
			_header.buttonWidths = buttonWidths;
			_header.widthType = ButtonBarModel.PIXEL_WIDTHS;
			_header.addBead(bblayout);
			_header.addBead(new Viewport());
			host.addElement(_header);
			
			host.addElement(_listArea);
				
			handleDataProviderChanged(event);
			
			host.addEventListener("widthChanged", handleSizeChanges);
			host.addEventListener("heightChanged", handleSizeChanges);
			
			host.dispatchEvent(new Event("dataGridViewCreated"));
			host.dispatchEvent(new Event("layoutNeeded"));
		}
		
		/**
		 * @private
		 */
		private function handleSizeChanges(event:Event):void
		{
			_header.dispatchEvent(new Event("layoutChanged"));
			_listArea.dispatchEvent(new Event("layoutChanged"));
		}
		
		/**
		 * @private
		 */
		private function handleDataProviderChanged(event:Event):void
		{
			host.dispatchEvent(new Event("layoutNeeded"));
		}
		
		/**
		 * @private
		 */
		private function handleSelectedIndexChanged(event:Event):void
		{
			var sharedModel:IDataGridModel = _strand.getBeadByType(IBeadModel) as IDataGridModel;
			var newIndex:int = sharedModel.selectedIndex;
			
			for(var i:int=0; i < _lists.length; i++) {
				if (_lists[i] is List) {
					(_lists[i] as List).selectedIndex = newIndex;
				}
			}
		}
		
		/**
		 * @private
		 */
		private function handleColumnListChange(event:Event):void
		{
			var sharedModel:IDataGridModel = _strand.getBeadByType(IBeadModel) as IDataGridModel;
			
			if (event.target is List) {
				var list:List = event.target as List;
				sharedModel.selectedIndex = list.selectedIndex;
			}
			else {
				return;
			}
			
			host.dispatchEvent(new Event('change'));
		}
		
		/**
		 * @private
		 */
		private function createColumns():void
		{
			var host:TreeGrid = _strand as TreeGrid;
			
			// get the name of the class to use for the columns
			var columnClassName:String = ValuesManager.valuesImpl.getValue(host, "columnClassName") as String;
			if (columnClassName == null) {
				columnClassName = "TreeGridColumn";
			}
			
			var presentationModel:IDataGridPresentationModel = host.presentationModel;
			var sharedModel:IDataGridModel = host.model as IDataGridModel;
			
			_lists = new Array();
			
			for (var i:int=0; i < sharedModel.columns.length; i++) {
				var columnDef:IDataGridColumn = sharedModel.columns[i] as IDataGridColumn;
				var useClassName:String = columnClassName;
				if (columnDef.className != null) useClassName = columnDef.className;
				
				var column:List = columnDef.createColumn() as List;
				
				if (i == 0)
				{
					column.className = "first "+useClassName;
				}
				else if (i == sharedModel.columns.length-1)
				{
					column.className = "last "+useClassName;
				}
				else
				{
					column.className = "middle "+useClassName;
				}
				
				// For the TreeGrid, the List columns must use this
				// model and itemRenderer factory to be compatible 
				// with the Tree column
				if (!(column is Tree)) {
					column.model = new SingleSelectionCollectionViewModel();
					column.addBead(new DataItemRendererFactoryForCollectionView());
				}
				
				column.id = "treeGridColumn" + String(i);
				column.dataProvider = sharedModel.dataProvider;
				column.labelField = columnDef.dataField;
				column.itemRenderer = columnDef.itemRenderer;
				column.addBead(presentationModel);
				column.addBead(new Viewport());
				column.addEventListener('change', handleColumnListChange);
				
				_listArea.addElement(column);
				_lists.push(column);
				
			}
			
			host.dispatchEvent(new Event("layoutNeeded"));
		}
	}
}