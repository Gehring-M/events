<!DOCTYPE html>
<html lang="de">
<head>
	
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Multiupload</title>
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	
<style>

	body {
		margin: 0;
		padding: 0;
		min-height: 100vh;
		font-family: arial, "Lucida Grande", "Lucida Sans Unicode", "Lucida Sans", "DejaVu Sans", Verdana, "sans-serif";
		font-size: 14px;
	}

	body * {
		margin: 0;
		padding: 0;
		box-sizing: border-box;
	}

	form {
		height: 100%;
	}

	.ag-f-drop-target {
		height: 100vh;
		background-color: rgba(120,120,135,0.50);
		transition: all .3s;
	}	
	.ag-f-drop-target:hover{
		background-color: rgba(120,120,135,0.30);
	}

	.ag-f-drop-wrapper {
		position: absolute;
		left: 0;
		top: 0;
		right: 0;
		bottom: 0;


	}

	.ag-f-drop-wrapper [type=file] {
		display: none;
		position: absolute;
		left: 0;
		top: 0;
		right: 0;
		bottom: 0;
		z-index: 1;

	}		


	.ag-f-drop-target .ag-f-drop-indicator:before {
		color: inherit;
		display: block;
		content: url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0idXRmLTgiPz4NCjwhLS0gR2VuZXJhdG9yOiBBZG9iZSBJbGx1c3RyYXRvciAyNy44LjEsIFNWRyBFeHBvcnQgUGx1Zy1JbiAuIFNWRyBWZXJzaW9uOiA2LjAwIEJ1aWxkIDApICAtLT4NCjxzdmcgdmVyc2lvbj0iMS4xIiBpZD0iRWJlbmVfMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayIgeD0iMHB4IiB5PSIwcHgiDQoJIHZpZXdCb3g9IjAgMCAyNCAyNCIgc3R5bGU9ImVuYWJsZS1iYWNrZ3JvdW5kOm5ldyAwIDAgMjQgMjQ7IiB4bWw6c3BhY2U9InByZXNlcnZlIj4NCjxzdHlsZSB0eXBlPSJ0ZXh0L2NzcyI+DQoJLnN0MHtmaWxsOiM3MDgwOTA7fQ0KPC9zdHlsZT4NCjxwYXRoIGNsYXNzPSJzdDAiIGQ9Ik0xMC41LDE4VjUuOEw2LjYsOS43TDQuNSw3LjVMMTIsMGw3LjUsNy41bC0yLjEsMi4ybC0zLjktMy45VjE4SDEwLjV6IE0zLDI0Yy0wLjgsMC0xLjUtMC4zLTIuMS0wLjkNCglTMCwyMS44LDAsMjF2LTQuNWgzVjIxaDE4di00LjVoM1YyMWMwLDAuOC0wLjMsMS41LTAuOSwyLjFDMjIuNSwyMy43LDIxLjgsMjQsMjEsMjRIM3oiLz4NCjwvc3ZnPg0K');
		position: absolute;
		left: 50%;
		top: 110px;
		transform: translate(-50%, -50%);
		width: 45px;
		heigth: auto;
	}	

	.ag-f-drop-target .ag-f-drop-indicator:after {
		color: darkslategray;
		display: block;
		content: attr(data-hint);
		font-size: 1em;
		position: absolute;
		left: 0;
		top: 150px;
		width: 100%;
		text-align: center;
	}	

	.ag-message{
		position: absolute;
		left: 7px;
		top: 7px;
		right: 7px;
		z-index: 2;
		background-color: darkseagreen;
		color: darkslategray;
		text-align: center;
		width: calc(100% - 14px);
		padding: 1em;
		line-height: 1.3em
	}

	.ag-message.ui-state-error {
		background-color: darkred;
		color: white
	}

</style>	
	
<script type="text/javascript" src="/js/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="/js/jquery-ui.min.js"></script>
<script type="text/javascript" src="/js/jquery.fileupload.js"></script>	
	
<script type="text/javascript">
		
		$(document).ready(function(){
			var fileMaxSize = 10000000;
			
			$('[type=file]').each(function () {
				var $upload = $(this),
					$container = $upload.parents('.ag-f-drop-target'),
					$fileList = $container,
					cData = $upload.parent().data(),
					state = 'error',
					errorObj = {'filesize':[],'filetype':[]},
					fileCount = 0;
				
				if (!$container.data('isMultiple') && $fileList.children().length) {
					$fileList.children().data('backup',$container)
					$container.detach();
				}
				$upload.fileupload({
					url: '/modules/remote/files.cfc?method=upload',
					formData: {
						restrictTo: cData.fileTypes,
						cFileFieldname:$upload.attr('name'),
						cFormFieldname:$upload.data('fieldId'),
						uploadTyp:$container.data('uploadTyp'),
						uploadBereich:$container.data('uploadBereich'),
						isMultiple:$container.data('isMultiple')
					},
					dropZone: $(this).parent(),
					add: function (e,data){
						var message = "";
						if (!$container.data('isMultiple') && data.originalFiles.length > 1) {
							message = "Nur eine Datei zum Hochladen wählen.";
						} else {
							$.each(data.files,function(index,item){

								if ($.inArray(item.type,cData.fileTypes.split(',')) != -1) {
									if (item.size <= fileMaxSize) {
										data.submit();
										state = '';
									} else {
										message = "Dateien dürfen nicht größer als " + fileMaxSize/1000000 + "MB sein";
										data.files.splice(index,1);
										errorObj.filesize.push(data.originalFiles[fileCount])
									}
								} else {
									message = "Unerlaubter Dateityp";
									console.log(item.type);
									data.files.splice(index,1);
									errorObj.filetype.push(data.originalFiles[fileCount])
								}								
								fileCount++;
							});
						}
						
						if (fileCount === data.originalFiles.length) {
							applyUserMessage($fileList,errorObj);
							errorObj = {'filesize':[],'filetype':[]};
							fileCount = 0;
						}
					}
					
				});
				
				
			
			});
			
			
			$(document).bind('dragover', function (e) {
				var dropZones = $('.ag-f-drop-target'),
					timeout = window.dropZoneTimeout;
				if (timeout) {
					clearTimeout(timeout);
				} else {
					dropZones.addClass('ag-drop-in');
				}
				var hoveredDropZone = $(e.target).closest(dropZones);
				dropZones.not(hoveredDropZone).removeClass('ag-drop-hover');
				hoveredDropZone.addClass('ag-drop-hover');
				window.dropZoneTimeout = setTimeout(function () {
					window.dropZoneTimeout = null;
					dropZones.removeClass('ag-drop-in ag-drop-hover');
				}, 100);
			});
			$(document).bind('drop dragover', function (e) {
				e.preventDefault();
			});
			$(document).on('mouseenter mouseleave','.ag-f-drop-target', function (e) {
				$(this).toggleClass('ag-drop-hover',e.type==='mouseenter');
			});
			
			function applyUserMessage(item,eObj) {
				
				if (eObj.filesize.length === 0 && eObj.filetype.length === 0){
					userMessage = $('<p class="ag-message ui-state-highlight">').html('Die Datei(en) wurden erfolgreich hochgeladen.');
					item.before(userMessage.delay(4000).slideUp(function(){userMessage.remove()}));
				} else {
					tmpErrorMsg = "Folgende Datei(en) konnten nicht erfolgreich hochgeladen werden:";
					if (eObj.filesize.length > 0) {
						$.each(eObj.filesize,function(index,item){
							tmpErrorMsg += "<p><b>"+item.name+"</b> (Datei zu groß)</p>"; 
						});
					}
					if (eObj.filetype.length > 0) {
						$.each(eObj.filetype,function(index,item){
							tmpErrorMsg += "<p><b>"+item.name+"</b> (Ungültiger Dateityp)</p>"; 
						});
					}
					userMessage = $('<div class="ag-message ui-state-error">').html(tmpErrorMsg);
					item.before(userMessage.delay(10000).slideUp(function(){userMessage.remove()}));
					
				}
			}
		});
		
		function parseOptions(str) {
			var obj = {},arr,len,val,i;

			// Remove spaces before and after delimiters
			str = str.replace(/\s*:\s*/g, ':').replace(/\s*,\s*/g, ',');

			// Parse a string
			arr = str.split(',');
			for (i = 0, len = arr.length; i < len; i++) {
				arr[i] = arr[i].split(':');
				val = arr[i][1];

			// Convert a string value if it is like a boolean
			if (typeof val === 'string' || val instanceof String) {
				val = val === 'true' || (val === 'false' ? false : val);
			}

			// Convert a string value if it is like a number
			if (typeof val === 'string' || val instanceof String) {
				val = !isNaN(val) ? +val : val;
			}

			obj[arr[i][0]] = val;
			}

			return obj;
		}
	</script>
	<cfset allowedFileTypes ="image/jpeg,image/png,image/gif,application/pdf,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/msword,application/vnd.ms-powerpoint,application/vnd.openxmlformats-officedocument.presentationml.presentation">
	<cfset hint ="Dateien innerhalb der grauen Fläche ablegen.">
	<cfif StructKeyExists(url,'typ') AND url['typ'] EQ "Bilder">
		<cfset hint ="Bilder innerhalb der grauen Fläche ablegen.">
		<cfset allowedFileTypes ="image/jpeg,image/png,image/gif">
	</cfif>
</head>
<body>
	<form action="" method="post" name="form" autocomplete="off">
		<cfoutput>
			<div class="ag-f-drop-target" data-is-multiple="1" data-upload-typ="#url['typ']#" data-upload-bereich="#url['bereich']#">
				<div class="ag-f-drop-indicator" data-hint="#hint#"></div>
				<div class="ag-f-drop-wrapper" id="target_droploader" data-file-types="#allowedFileTypes#">
					<input type="file" class="ag-f-x6" name="_droploader" data-field-id="droploader" multiple />
				</div>
			</div>
		</cfoutput>
	</form>
</body>
</html>