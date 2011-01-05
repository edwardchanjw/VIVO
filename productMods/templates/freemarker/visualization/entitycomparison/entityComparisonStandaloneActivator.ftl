<#-- $This file is distributed under the terms of the license in /doc/license.txt$ -->

<#assign standardVisualizationURLRoot ="/visualizationfm">
<#assign ajaxVisualizationURLRoot ="/visualizationAjax">
<#assign dataVisualizationURLRoot ="/visualizationData">

<#assign organizationURI ="${organizationURI?url}">
<#assign jsonContent ="${jsonContent}">
<#assign organizationLabel = "${organizationLabel}">
<#assign organizationVivoProfileURL = "${urls.base}/individual?uri=${organizationURI}">


<#assign temporalGraphSmallIcon = '${urls.images}/visualization/temporal_vis_small_icon.jpg'>


<#assign TemporalGraphDownloadFile = '${urls.base}${dataVisualizationURLRoot}?vis=entitycomparison&uri=${organizationURI}&labelField=label'>


<#-- Javascript files -->

<#assign flot = '${urls.base}/js/visualization/entitycomparison/jquery_plugins/flot/jquery.flot.js'>
<#assign fliptext = '${urls.base}/js/visualization/entitycomparison/jquery_plugins/fliptext/jquery.mb.flipText.js'>
<#assign jgrowl = '${urls.base}/js/visualization/entitycomparison/jquery_plugins/jgrowl/jquery.jgrowl.js'>
<#assign datatable = '${urls.base}/js/visualization/entitycomparison/jquery_plugins/datatable/jquery.dataTables.js'>
<#assign autoellipsis = '${urls.base}/js/visualization/entitycomparison/jquery_plugins/jquery.AutoEllipsis.js'>

<#assign entityComparisonUtils = '${urls.base}/js/visualization/entitycomparison/util.js'>
<#assign entityComparisonConstants = '${urls.base}/js/visualization/entitycomparison/constants.js'>

<script type="text/javascript" src="${flot}"></script>
<script type="text/javascript" src="${fliptext}"></script>
<script type="text/javascript" src="${jgrowl}"></script>
<script type="text/javascript" src="${datatable}"></script>
<script type="text/javascript" src="${autoellipsis}"></script>
<script type="text/javascript" src="${entityComparisonUtils}"></script>
<script type="text/javascript" src="${entityComparisonConstants}"></script>

<#-- CSS files -->


<#assign jgrowlStyle = "${urls.base}/js/visualization/entitycomparison/jquery_plugins/jgrowl/jquery.jgrowl.css" />
<#assign demoTable = "${urls.base}/js/visualization/entitycomparison/jquery_plugins/datatable/demo_table.css" />

<#assign entityComparisonStyle = "${urls.base}/css/visualization/entitycomparison/layout.css" />
<#assign vizStyle = "${urls.base}/css/visualization/visualization.css" />

<link href="${jgrowlStyle}" rel="stylesheet" type="text/css" />
<link href="${demoTable}" rel="stylesheet" type="text/css" />
<link href="${entityComparisonStyle}" rel="stylesheet" type="text/css" />
<link href="${vizStyle}" rel="stylesheet" type="text/css" />


<#-- variables passed from server-side code -->
<script language="JavaScript" type="text/javascript">
	
var contextPath = "${urls.base}";
var temporalGraphDownloadFile = "${TemporalGraphDownloadFile}"
var temporalGraphSmallIcon = "${temporalGraphSmallIcon}";

</script>

<script type="text/javascript">

	$(document).ready(function() {

		var jsonString = '${jsonContent}';
		var organizationLabel = '${organizationLabel}';   

		$("#organizationLabel").text(organizationLabel).css("color", "#2485ae");
		$("#organizationMoniker").text(organizationLabel);
		$("#organizationMoniker").attr("href", "${organizationVivoProfileURL}");
		
		var jsonObject = {
				prepare : function(arg1){
					loadData(arg1);
				}
			};
		
		graphContainer = $("#graphContainer");
		tableDiv = $('#paginatedTable');

 		// initial display of the grid when the page loads
 		init(graphContainer);
		
		/*
		 * When the intra-entity parameters are clicked,
		 * update the status accordingly.	
		 */	        
        $("select.comparisonValues").click(function(){
            var selectedValue = $("select.comparisonValues option:selected").val();
			$("#comparisonParameter").text("Total Number of " + selectedValue);
			$('#yaxislabel').html("Number of " + selectedValue).mbFlipText(false);
			$('#comparisonHeader').html(selectedValue).css('font-weight', 'bold');
        });

		//click event handler for clear button
		$("button#clear").click(function(){
			clearRenderedObjects();
		});

		//click event handler for download file
		$("button#csv").click(function(){
			  alert("${TemporalGraphDownloadFile}");
		});		
		
		$("input[type=checkbox].easyDeselectCheckbox").live('click', function(){
			
			var checkbox = $(this);
			var checkboxValue = $(this).attr("value");
			var linkedCheckbox = labelToCheckedEntities[checkboxValue];
			//console.log('checkbox value is '+ checkboxValue);
			var entityToBeRemoved = labelToEntityRecord[checkboxValue];

			if(!checkbox.is(':checked')){
				//console.log("Easy deselect checkbox is unclicked!");
				updateRowHighlighter(linkedCheckbox);
				removeUsedColor(entityToBeRemoved);
				removeEntityUnChecked(renderedObjects, entityToBeRemoved);                          
             	removeGraphic(linkedCheckbox);
             	removeCheckBoxFromGlobalSet(linkedCheckbox);
             	$(linkedCheckbox).attr('checked', false);
             	checkIfColorLimitIsReached();
                displayLineGraphs();
				updateCounter();				
    		}
		});
							
		//parse the json object and pass it to loadData
        jsonObject.prepare(jQuery.parseJSON(jsonString));

        /* 
         *  function to populate the labelToEntityRecord object with the
         *  values from the json file and
         *  dynamically generate checkboxes
         */
        function loadData(jsonData){
            
           // var yearRange;

            $.each(jsonData, function(index, val){
                setOfLabels.push(val.label);
                labelToEntityRecord[val.label] = val;
            });

			getEntityVisMode(jsonData);
			prepareTableForDataTablePagination(jsonData);
			setEntityLevel();
           // calcMinandMaxYears(labelToEntityRecord, year);
			//yearRange = (year.max - year.min);

           // setLineWidthAndTickSize(yearRange, FlotOptions);     
			//setTickSizeOfYAxis(calcMaxOfComparisonParameter(labelToEntityRecord), FlotOptions);
            /*
             * When the elements in the paginated div
             * are clicked this event handler is called
             */
            $("input.if_clicked_on_school").live('click', function(){
            
                var checkbox = $(this);
                var checkboxValue = $(this).attr("value");
                var entity = labelToEntityRecord[checkboxValue];
                
				//Dynamically generate the bar, checkbox and label.

                var bottomDiv = $("#bottom");
                var hiddenLabel = createGraphic(entity, bottomDiv);

                
                var divBar = hiddenLabel.next();
                var divLabel = hiddenLabel.prev();
                var spanElement = divBar.next('span');

                if (checkbox.is(':checked')) {
                	
					getNextFreeColor(entity);
					generateBarAndLabel(entity, divBar, divLabel,checkbox, spanElement) ; 
					renderLineGraph(renderedObjects, entity);
					labelToCheckedEntities[checkboxValue] = checkbox;
					                     
		        } else if (!checkbox.is(':checked')) {
		
					removeUsedColor(entity);
					removeEntityUnChecked(renderedObjects, entity);                          
		            removeGraphic(checkbox);
		            removeCheckBoxFromGlobalSet(checkbox);
		                     
		        	}
				//console.log('Number of checked entities: ' + getSize(labelToCheckedEntities));
				//disableUncheckedEntities();
				setTickSizeOfAxes();
				checkIfColorLimitIsReached();
		    	//populateMapOfCheckedEntities();                    
		        displayLineGraphs();
				updateCounter(); 
		
		    });
        }

	});
	
</script>

<div id="body">
		<h2 style="width: 36%; padding-left:45px;"><a href="" id = "organizationMoniker"></a></h2>
		<div id="leftblock">
			<div id="leftUpper">
				<h3>How do you want to compare?</h3>
				
				<div style="text-align: left;">
				
				<select class="comparisonValues" style="margin-bottom: 20px;">
					<option value="Publications" selected="selected">by Publications</option>
					<option value="Grants">by Grants</option>
<#--
					<option value="People" disabled="disabled">by People</option>
					<option value="Item4" disabled="disabled">by Item4</option>
					<option value="Item5" disabled="disabled">by Item5</option>
-->
				</select>
				
				</div>
			</div>
						
			<div id="leftLower">
				<h3>Who do you want to compare?</h3>
				<div id="paginatedTable">
				</div>
			</div>
			<div id = "stopwordsdiv">
				* The entity types core:Person, foaf:Organization have been excluded as they are too general.
			</div>	
		</div>
		<div id="rightblock">
		
			<h4 id="headerText" style="padding-left:60px;">Comparing <span id="comparisonHeader">Publications</span> of <span id="entityHeader">Institutions</span> in <span id="organizationLabel"></span></h4>
			<div id="graphContainer" style="width: 450px; height: 250px;"></div>
			<div id="yaxislabel"></div>
			
			<div id="bottom" style="width: 450px; height: 350px;">
				<div id="xaxislabel">Year</div>
		
				<div id="bottomButtons">
					<button id="clear" class="green-button" type ="button">Remove All</button>
					<button id="csv" class="green-button" class="green-button" type ="button">Save as CSV</button>
					<button id="image" class="green-button" type="button" onClick="window.print()"> Save as Image</button>				
				</div><br/>
		
				<h4><span id="comparisonParameter"></span></h4>
		
			<p class="displayCounter">You have selected <span id="counter">0</span> of a maximum <span
			id="total">10</span> <span id="entityleveltext"> schools</span> to compare.</p>
		
			</div>
		
		</div>		
</div>