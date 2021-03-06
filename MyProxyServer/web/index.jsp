<%-- 
/**************************************************************************
    Copyright (c) 2011:
    Istituto Nazionale di Fisica Nucleare (INFN), Italy
    Consorzio COMETA (COMETA), Italy

    See http://www.infn.it and and http://www.consorzio-cometa.it for details
    on the copyright holders.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Author(s): Giuseppe La Rocca (INFN), Salvatore Monforte (INFN)
     ****************************************************************************/
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page trimDirectiveWhitespaces="true"%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
<html>
  <head>
    <style type="text/css">
      body, html { font-family: Tahoma,Verdana,sans-serif,Arial; font-size: 14px; }
      #selected-attributes .ui-selecting { background: #FECA40; }
      #selected-attributes .ui-selected { background: #F39814; color: white; }
      #selected-attributes, #sorted-attributes { list-style-type: none; margin: 0; padding: 0; width: 50%; }
      #selected-attributes li, #sorted-attributes li { margin: 3px; padding: 4px; font-size: 12px; height: 16px; }
      #steps img { width:32px; border:0;}
      img.architecture { width:600px !important; height: 450px !important;}
    </style>
    <link  HREF="icon.ico">  
    <link href="ui/css/ticker.css" rel="stylesheet" type="text/css"/>
    <link href="ui/css/overcast/jquery-ui-1.8.13.custom.css" rel="stylesheet" type="text/css"/>
    <script type="text/javascript" src="ui/js/jquery-1.5.1.min.js"></script>
    <script type="text/javascript" src="ui/js/jquery-ui-1.8.13.custom.min.js"></script>
    <script type="text/javascript" src="ui/js/jQuery.rollChildren.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

    <title>MyProxy Servlet</title>
    <script  type="text/javascript" >
      var attributes = {};
      var associativeArray = [];

      $(document).ready(function() {  
      	$('#footer').rollchildren({  
		delay_time 	   : 3000,  
		loop 		   : true,  
		pause_on_mouseover : true,  
		roll_up_old_item   : true,  
		speed		   : 'slow'   
		});  
	}); 

      $(function()
      {
	var ticker = function()
	{
		setTimeout(function(){
		$('#ticker li:first').animate( {marginTop: '-120px'}, 800, function()
		{
			$(this).detach().appendTo('ul#ticker').removeAttr('style');
		});
		ticker();
	}, 6000);
	};
	ticker();
      });
      
      function enableCN(f)
      {
          if ($('#enable-cn-label').attr('checked')) {
                  $('input[name="cn-label"]').removeAttr('disabled');
                  $('#rfc-proxy').attr("checked",true);
          } else {
                  $('input[name="cn-label"]').val('Empty');
                  $('input[name="cn-label"]').attr('disabled','disabled');
                  $('#rfc-proxy').attr("checked",false);
          }
      }
      
      function enableDirac(f)
      {
          if ($('#dirac-token').attr('checked')) {
                $('#disable-voms-proxy').attr("checked",false);
                $('#rfc-proxy').attr("checked",false);
                $('#enable-cn-label').attr("checked",false);
          }
      }

      function update_request()
      {
        // Check if at least one AC have been selected.
        if( $( "#selected-attributes li.ui-selected").size() == 0) {
            if ($('input[name="disable-voms-proxy"]').attr('checked')== false) {
            $( "#steps div[name='error2']" ).show();
            $( "#steps" ).accordion('activate', 1);
            }
        } else {
          // For each selected AC(s), we update the request.
          var request ="<%=request.getRequestURL()%>eToken/";
          request +=  $("select#eToken option:selected").first().attr('value');
          var voms =[];
          $( "#sorted-attributes li").each(function() {
            voms.push($(this).attr('name') + ":"+ $(this).html());
          });
          request += "?voms=" + voms.join('+');
          request += "&proxy-renewal=" + $('input[name="long-proxy"]').attr('checked');
          request += "&disable-voms-proxy=" + $('input[name="disable-voms-proxy"]').attr('checked');
          request += "&rfc-proxy=" + $('input[name="rfc-proxy"]').attr('checked');          
          request += "&cn-label=" + $('input[name="cn-label"]').val();
          //request += "&dirac-token=" + $('input[name="dirac-token"]').attr('checked');
          
          $('#request').html(request);
        }
      }
      
      function showACAttributes(md5sum) {
         
        $( "#selected-attributes li").each(function() {$(this).remove();});
        $.each(attributes[md5sum], function(i,item){
          var vo = item.vo;
          $.each(item.fqans, function(i,fqan){
            $("<li />", {
              'name':vo,
              'class': 'ui-widget-content',
              html:fqan
            }).appendTo($('div#attributes ul'));
          });
        });
      }
      
      $(function(){
        $.getJSON('/eTokenServer/eToken?format=json', function(data) {
          var options = [];          
	  
          options.push('<option value=-1>Select one certificate from the drop-down list below</option>');
	  
          $.each(data, function(i,item) {
            //options.push('<option value="' + item.serial + '">' + item.label + '</option>');
            options.push('<option value="' + item.md5sum + '">' + item.subject + '</option>');
            attributes[item.md5sum]=item.attributes;

	    // Create an Array to hold all the certificate info.
	    associativeArray[item.md5sum] = item;
	    
          });
          
          $('select#eToken').html(options.join(''));
          showACAttributes($("select#eToken option").first().attr('value'));
          
          $( "#steps" ).accordion('resize');
        });
        
        // Onchange event retrieve the list of ACs for the given serial number
        $('select#eToken').bind('change', function() {
          var md5sum =  $("select#eToken option:selected").first().attr('value');
	  $('#details').css("display", "inline");
	  
	  // Removing old info
	  $('#details').html('');
	  var to = (associativeArray[md5sum].validto).split(" ");
	  var d1 = new Date();
	  var d2 = new Date(to[1]+" "+to[2]+", "+to[5]);

	  var days = 1000*60*60*24;
	  var diff = Math.ceil((d2.getTime()-d1.getTime())/(days));
	  
	  // Showing new details
	  $('#details').append("\nSerial\t\t=\t" + associativeArray[md5sum].serial + "\n");
	  $('#details').append("Label\t\t=\t" + associativeArray[md5sum].label + "\n");
          $('#details').append("MD5Sum\t\t=\t" + associativeArray[md5sum].md5sum + "\n");
	  $('#details').append("Subject\t\t=\t" + associativeArray[md5sum].subject + "\n");
	  $('#details').append("Issuer\t\t=\t" + associativeArray[md5sum].issuer + "\n");
	  $('#details').append("Valid from\t=\t" + associativeArray[md5sum].validfrom + "\n");
	  $('#details').append("Valid to\t\t=\t" + associativeArray[md5sum].validto + "\n");
          if (diff>0) $('#details').append("Expiration\t\t=\tThis certificate will expire in " + diff + " days! \n\n");
          else $('#details').append("Expiration\t\t=\tThis certificate expired " + Math.abs(diff) + " days ago! \n\n");
	  $('#details').append("Signature\t\t=\t" + associativeArray[md5sum].signature + "\n");
	  $('#details').append("OID\t\t\t=\t" + associativeArray[md5sum].oid + "\n");
	  $('#details').append("Public\t\t=\t" + associativeArray[md5sum].publiccert + "\n");
	    
          showACAttributes(md5sum);
        });
        
        $( "#selected-attributes" ).selectable({stop: function() {
            $( "#sorted-attributes li").each(function() {$(this).remove();});
            $( "#selected-attributes li.ui-selected").each(function(i, item) {
              $(item).clone().appendTo($( "#sorted-attributes"));
            });
          }});
        $( "#sorted-attributes" ).sortable({placeholder: "ui-state-highlight"}).enableSelection();        
      });
      
      $(function() {
        $( "#steps" ).accordion({autoHeight: false, navigation: true});
        $('.ui-accordion').bind('accordionchange', function(event, ui) {
                    
        //alert($('input[name="disable-voms-proxy"]').attr('checked'));                    
          if ($("#selected-attributes li.ui-selected").size() == 0)       
          if ($('input[name="disable-voms-proxy"]').attr('checked')==true) {
            $( "#steps div[name='error3']" ).show();
          }
          else {
               $( "#steps div[name='error2']" ).hide();
               $( "#steps div[name='error3']" ).hide();
          }
          if ($(ui.newContent).find('#request').size() == 1) {
            update_request();
          }
        });
      });
</script>

<style>
.slide-out-div {
    padding: 5px;
    width: 250px;
    background: white;
    border: 1px solid #29216d;
}
</style>
</head>
  
<body>
<h1>Create your own long-term proxy!
<a href="http://www.garr.it/">
<img width="250" src="images/GARR_logo.png" 
     border="0" title="Consortium GARR - La Rete Italiana dell'Universita' e della Ricerca"></a>

<a href="http://www.infn.it/">
<span>
<img width="150" src="http://www.infn.it/logo/weblogo1.gif" border="0" 
     title="INFN - Istituto Nazionale di Fisica Nucleare">
</span>
</a>
</h1>

<!--div id="steps" 
     style="width:70%; font-family: Tahoma,Verdana,sans-serif,Arial; font-size: 14px;">
<h2><a href="#">
<span>
<img width="32" 
     align="absmiddle" 
     src="images/png/glass_numbers_1.png"> Choose the certificate</a>
</span>
</a>
</h2>
<div>
<select class="ui-widget ui-widget-content" id="eToken" name="eToken"></select>
<textarea class="ui-widget ui-widget-content" id="details" name="details" 
          style="width: 820px; height: 250px; display:none" disabled="disabled">
</textarea>
</div>
      
<h2>
<a href="#">
<img width="32" 
     align="absmiddle" 
     src="images/png/glass_numbers_2.png"> Add AC attributes</a>
</h2>
<div>
<p>Select AC attributes to add to the generated proxy.</p>
<div name="error2" class="ui-widget" style="float:right;display:none;">
<div class="ui-state-error ui-corner-all" style="padding: 0 .7em;">
<p>
<span class="ui-icon ui-icon-alert" style="float: left; margin-right: .3em;"></span>
<strong>Alert:</strong>
Please select at least one AC Attribute
</p>
</div>
</div>
<div id="attributes">
<ul id="selected-attributes">
</ul>
</div>
<p><small>Hold CTRL to select/deselect multiple entries</small></p>
</div>
  
<h2>
<a href="#">
<img width="32" 
     align="absmiddle"
     src="images/png/glass_numbers_3.png"> AC attributes order</a>
</h2>
<div>
<p>Choose the FQANs order which best fits your needs</p>
<div name="error3" class="ui-widget"  style="float:right;display:none;">
<div class="ui-state-highlight ui-corner-all" style="margin-top: 20px; padding: 0 .7em;">
<p>
<span class="ui-icon ui-icon-info" style="float: left; margin-right: .3em;"></span>
<strong>Hey!</strong>
Select some AC Attributes first!
</p>
</div>
</div>
<div>
<ul id="sorted-attributes">
</ul>
</div>
</div>
  
<h2>
<a href="#">
<img width="32" 
     align="absmiddle"
     src="images/png/glass_numbers_4.png"> Choose Options</a>
</h2>
<div>
<p>- Use the options below as you need</p>
<label for="long-proxy">Enable Proxy Renewal:</label>
<input type="checkbox" name="long-proxy" id="long-proxy"/>
<label for="disable-voms-proxy">Disable VOMS Proxy:</label>
<input type="checkbox" name="disable-voms-proxy" id="disable-voms-proxy"/>
<label for="rfc-proxy">Create RFC Proxy:</label>
<input type="checkbox" name="rfc-proxy" id="rfc-proxy"/><br/><br/>
<!--label for="dirac-token">Create Dirac Token:</label>
- Add some additional info to account users of robot proxy certificates<br/><br/>
<label for="enable-cn-enable">Enable CN:</label>
<input type="checkbox" name="enable-cn-label" id="enable-cn-label" onchange="enableCN(this.form);"/>
<input type="text" name="cn-label" disabled value="Empty"/>
</div>
    
<h3>
<a href="#">
<img  width="32"  
      align="absmiddle"
      src="images/png/glass_numbers_5.png"> Get your request</a>
</h3>
<div>
<p>Here is your request</p>
<div id="request" class="ui-widget ui-state-highlight ui-corner-all"></div>
</div>    
    
<h3>
<a href="#">
<img  width="32"  
      align="absmiddle"
      src="images/png/glass_numbers_6.png"> Get info</a>
</h3>
<div align="justify">
<p>
    The "light-weight" grid-based crypto library interface has been designed to provide
   seamless and secure access to computing e-Infrastructures, based on gLite middleware,
   and other middleware supporting X.509 standard for authorization, using robot certificate.
   <br/><br/>
   By design the the eTokenServer is compliant with the policies reported in the two documents:<br/><br/>
   ~ <a href="http://www.eugridpma.org/guidelines/pkp/">EUGridPMA guidelines</a><br/>
   ~ <a href="http://wiki.eugridpma.org/Main/CredStoreOperationsGuideline">OperationsGuideline</a>
   <br/><br/>
   The business logic of the library, deployed on top of an Apache Tomcat Application Server,
   combines different programming native interfaces and standards such as:<br/><br/>
   
   ~ the “cryptoki” Java™ Cryptographic Token Standard Interface (PKCS#11) libraries,<br/>
   ~ the open source BouncyCastle libraries,<br/>
   ~ the Java CoG Kits APIs,<br/>
   ~ the VOMS-Admin APIs,<br/>
   ~ RESTful technology (JSR 311).<br/><br/>
   
   The five-layer architecture of the library interface is shown in fig.1<br/>
</p>
<div align="center">
<img class="architecture" src="images/architecture.png" border="0"/>
</div>

<div align="center">
<p>
    <br/>
    In fig.2 are shown the list of eTokenServer installations (being) supported 
    by the CHAIN-REDS project
</p>
<img class="architecture" src="images/maps.png" border="0"/>
</div>
</div>
</div-->

<div id='footer' font-family: Tahoma,Verdana,sans-serif,Arial; font-size: 14px;">  
<div>Istituto Nazionale di Fisica Nucleare (INFN), Catania, Italy</div>
<div>MyProxy servlet ver. 2.0.1</div>
<div>Copyright © 2010 - 2014. All rights reserved</div>  
<div>This work has been partially supported by
<a href="http://www.egi.eu/projects/egi-inspire/">
<img width="35" 
     border="0"
     src="images/EGI_Logo_RGB_315x250px.png" 
     title="The European Grid Infrastructure"/>
</a>
</div>  
</div> 

</body>
</html>
