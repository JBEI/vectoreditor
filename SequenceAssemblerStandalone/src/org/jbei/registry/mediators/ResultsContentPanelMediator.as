package org.jbei.registry.mediators
{
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    import mx.controls.dataGridClasses.DataGridColumn;
    
    import org.jbei.registry.ApplicationFacade;
    import org.jbei.registry.Notifications;
    import org.jbei.registry.models.AssemblyProvider;
    import org.jbei.registry.models.Permutation;
    import org.jbei.registry.models.PermutationSet;
    import org.jbei.registry.view.ui.results.ResultsContentPanel;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
    
    /**
     * @author Zinovii Dmytriv
     */
    public class ResultsContentPanelMediator extends Mediator
    {
        public static const MEDIATOR_NAME:String = "ResultsContentPanelMediator";
        
        private var resultsContentPanel:ResultsContentPanel;
        
        // Constructor
        public function ResultsContentPanelMediator(viewComponent:Object=null)
        {
            super(MEDIATOR_NAME, viewComponent);
            
            resultsContentPanel = viewComponent as ResultsContentPanel;
        }
        
        // Public Methods
        public override function handleNotification(notification:INotification):void
        {
            switch(notification.getName()) {
                case Notifications.UPDATE_RESULTS_PERMUTATIONS_TABLE:
                    updateResultsPermutationsTable(ApplicationFacade.getInstance().resultPermutations);
                    
                    break;
            }
        }
        
        public override function listNotificationInterests():Array
        {
            return [Notifications.UPDATE_RESULTS_PERMUTATIONS_TABLE];
        }
        
        // Private Methods
        private function updateResultsPermutationsTable(resultPermutations:PermutationSet):void
        {
            var assemblyProvider:AssemblyProvider = ApplicationFacade.getInstance().assemblyProvider;
            
            var columns:Array = new Array();
            
            for(var i:int = 0; i < assemblyProvider.bins.length; i++) {
                var dataGridColumn:DataGridColumn = new DataGridColumn(assemblyProvider.bins[i].featureType.name);
                
                dataGridColumn.dataField = "col" + String(i);
                dataGridColumn.sortable = false;
                dataGridColumn.draggable = false;
                
                columns.push(dataGridColumn);
            }
            
            resultsContentPanel.resultsDataGrid.dataProvider = null;
            
            resultsContentPanel.resultsDataGrid.columns = columns;
            
            var permutationDataProvider:ArrayCollection = new ArrayCollection();
            
            for(var j:int = 0; j < resultPermutations.permutations.length; j++) {
                var permutation:Permutation = resultPermutations.permutations[j];
                
                var providerItem:Dictionary = new Dictionary();
                
                for(var k:int = 0; k < permutation.items.length; k++) {
                    providerItem["col" + String(k)] = permutation.items[k];
                }
                
                permutationDataProvider.addItem(providerItem);
            }
            
            resultsContentPanel.resultsDataGrid.dataProvider = permutationDataProvider;
            
            sendNotification(Notifications.RESULTS_ACTION_MESSAGE, String(permutationDataProvider.length) + " sequences were built");
        }
    }
}