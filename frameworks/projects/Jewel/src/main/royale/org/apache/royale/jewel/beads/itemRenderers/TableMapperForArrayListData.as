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
package org.apache.royale.jewel.beads.itemRenderers
{
	import org.apache.royale.jewel.supportClasses.table.TableColumn;
	import org.apache.royale.jewel.beads.models.TableModel;
    import org.apache.royale.jewel.supportClasses.table.THead;
    import org.apache.royale.jewel.supportClasses.table.TBody;
    import org.apache.royale.jewel.supportClasses.table.TFoot;
	import org.apache.royale.jewel.beads.views.TableView;
	
	import org.apache.royale.collections.ArrayList;
    import org.apache.royale.core.IItemRendererParent;
	import org.apache.royale.core.IBead;
	import org.apache.royale.core.IBeadModel;
	import org.apache.royale.core.IBeadView;
	import org.apache.royale.core.IStrand;
	import org.apache.royale.events.Event;
	import org.apache.royale.events.IEventDispatcher;
	import org.apache.royale.jewel.Label;
	import org.apache.royale.jewel.Table;
	import org.apache.royale.jewel.TableCell;
	import org.apache.royale.jewel.TableHeader;
	import org.apache.royale.jewel.TableRow;
	import org.apache.royale.jewel.itemRenderers.TableItemRenderer;
    import org.apache.royale.core.IDataProviderItemRendererMapper;
    import org.apache.royale.core.IItemRendererClassFactory;
    import org.apache.royale.utils.loadBeadFromValuesManager;
	
	public class TableMapperForArrayListData implements IBead, IDataProviderItemRendererMapper
	{
		public function TableMapperForArrayListData()
		{
		}
		
		private var _strand:IStrand;
		
		public function set strand(value:IStrand):void
		{
			_strand = value;
			
			IEventDispatcher(_strand).addEventListener("tableComplete", handleInitComplete);
		}

        private var _itemRendererFactory:IItemRendererClassFactory;
		
		/**
		 *  The org.apache.royale.core.IItemRendererClassFactory used
		 *  to generate instances of item renderers.
		 *
		 *  @langversion 3.0
		 *  @playerversion Flash 10.2
		 *  @playerversion AIR 2.6
		 *  @productversion Royale 0.9.3
		 *  @royaleignorecoercion org.apache.royale.core.IItemRendererClassFactory
		 */
		public function get itemRendererFactory():IItemRendererClassFactory
		{
			if(!_itemRendererFactory)
				_itemRendererFactory = loadBeadFromValuesManager(IItemRendererClassFactory, "iItemRendererClassFactory", _strand) as IItemRendererClassFactory;
			
			return _itemRendererFactory;
		}
		
		/**
		 *  @private
		 */
		public function set itemRendererFactory(value:IItemRendererClassFactory):void
		{
			_itemRendererFactory = value;
		}
		
		private function handleInitComplete(event:Event):void
		{
			var model:TableModel = _strand.getBeadByType(IBeadModel) as TableModel;
			if (model == null) return;

			var view:TableView = _strand.getBeadByType(IBeadView) as TableView;
			
			var dp:ArrayList = model.dataProvider as ArrayList;
			if (dp == null || dp.length == 0) return;
			
			var table:Table = _strand as Table;
            var dataGroup:IItemRendererParent = table.dataGroup;
			
			var createHeaderRow:Boolean = false;
            var test:TableColumn;
            var c:int;
			for(c=0; c < model.columns.length; c++)
			{
				test = model.columns[c] as TableColumn;
				if (test.label != null) {
					createHeaderRow = true;
					break;
				}
			}

            var thead:THead;
            var row:TableRow;
			if (createHeaderRow) {
                thead = new THead();
				row = new TableRow();
				
				for(c=0; c < model.columns.length; c++)
				{
					test = model.columns[c] as TableColumn;
					var tableHeader:TableHeader = new TableHeader();
					var label:Label = new Label();
					tableHeader.addElement(label);
					label.text = test.label == null ? "" : test.label;
					row.addElement(tableHeader);
				}

				thead.addElement(row);
				table.addElement(thead);
			}
			
            var tbody:TBody = view.tbody;
            table.addElement(tbody);

            var column:TableColumn;
            var tableCell:TableCell;
            var ir:TableItemRenderer;

			for(var i:int=0; i < dp.length; i++)
			{
				row = new TableRow();
				
				for(var j:int=0; j < model.columns.length; j++)
				{
					column = model.columns[j] as TableColumn;
					tableCell = new TableCell();
					
                    if(column.itemRenderer != null)
                    {
                        ir = column.itemRenderer.newInstance() as TableItemRenderer;
                    } else
                    {
                        ir = itemRendererFactory.createItemRenderer(dataGroup) as TableItemRenderer;
                    }
                    
					tableCell.addElement(ir);
					row.addElement(tableCell);
					
					ir.labelField = column.dataField;
					ir.index = i;
					ir.data = dp.getItemAt(i);

                    if(column.align != "")
                    {
                        ir.align = column.align;
                    }
				}
				
				tbody.addElement(row);
			}
			
			table.dispatchEvent(new Event("layoutNeeded"));
		}
	}
}
