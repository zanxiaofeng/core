<%
boolean access = APILocator.getLayoutAPI().doesUserHaveAccessToPortlet(portlet.getPortletId(),user);
String licenseManagerOverrideTicket = (String)request.getParameter("licenseManagerOverrideTicket");
String roleAdminOverrideTicket = (String)request.getParameter("roleAdminOverrideTicket");
if(roleAdminOverrideTicket!=null){
	if(request.getSession().getAttribute("roleAdminOverrideTicket")!=null){
	  String overrideTicket = (String)request.getSession().getAttribute("roleAdminOverrideTicket");
	   if(overrideTicket!=null && roleAdminOverrideTicket.equalsIgnoreCase(overrideTicket)){
		  access = true;
	   }
	}
}

if(licenseManagerOverrideTicket!=null){
	if(request.getSession().getAttribute("licenseManagerOverrideTicket")!=null){
	  String overrideTicket = (String)request.getSession().getAttribute("licenseManagerOverrideTicket");
	   if(overrideTicket!=null && licenseManagerOverrideTicket.equalsIgnoreCase(overrideTicket)){
		  access = true;
	   }
	}
}


CachePortlet cachePortlet = null;
try {
	cachePortlet = PortalUtil.getPortletInstance(portlet, application);
}
/*catch (UnavailableException ue) {
	ue.printStackTrace();
}*/
catch (PortletException pe) {
	pe.printStackTrace();
}
catch (RuntimeException re) {
	re.printStackTrace();
}

//PortletPreferences portletPrefs = PortletPreferencesManagerUtil.getPreferences(company.getCompanyId(), PortalUtil.getPortletPreferencesPK(request, portlet.getPortletId()));
PortletPreferences portletPrefs = null;

PortletConfig portletConfig = PortalUtil.getPortletConfig(portlet, application);
PortletContext portletCtx = portletConfig.getPortletContext();


// Passing in a dynamic request with box_width makes it easier to render
// portlets, but will break the TCK because the request parameters will have an
// extra parameter


RenderRequestImpl renderRequest = new RenderRequestImpl(request, portlet, cachePortlet, portletCtx, null, null, portletPrefs, layoutId);

StringServletResponse stringServletRes = new StringServletResponse(response);

RenderResponseImpl renderResponse = new RenderResponseImpl(renderRequest, stringServletRes, portlet.getPortletId(), company.getCompanyId(), layoutId);

renderRequest.defineObjects(portletConfig, renderResponse);


int portletTitleLength = 12;

Map portletViewMap = CollectionFactory.getHashMap();

portletViewMap.put("access", new Boolean(access));
portletViewMap.put("active", new Boolean(portlet.isActive()));

portletViewMap.put("portletId", portlet.getPortletId());
portletViewMap.put("portletTitleLength", new Integer(portletTitleLength));

portletViewMap.put("restoreCurrentView", new Boolean(portlet.isRestoreCurrentView()));

renderRequest.setAttribute(WebKeys.PORTLET_VIEW_MAP, portletViewMap);

if ((cachePortlet != null) && cachePortlet.isStrutsPortlet()) {

	// Make sure the Tiles context is reset for the next portlet

	request.removeAttribute(com.dotcms.repackage.org.apache.struts.taglib.tiles.ComponentConstants.COMPONENT_CONTEXT);
}

boolean portletException = false;

if (portlet.isActive() && access) {
	try {
		cachePortlet.render(renderRequest, renderResponse);
	}
	catch (UnavailableException ue) {
		portletException = true;

		PortalUtil.destroyPortletInstance(portlet);
	}
	catch (Exception e) {
		portletException = true;

		e.printStackTrace();
	}

	SessionMessages.clear(renderRequest);
	SessionErrors.clear(renderRequest);
}

boolean showPortletAccessDenied = portlet.isShowPortletAccessDenied();
boolean showPortletInactive = portlet.isShowPortletInactive();

	if ((cachePortlet != null) && cachePortlet.isStrutsPortlet()) {
		if (!access || portletException) {
			PortletRequestProcessor portletReqProcessor = (PortletRequestProcessor)portletCtx.getAttribute(WebKeys.PORTLET_STRUTS_PROCESSOR);

			ActionMapping actionMapping = portletReqProcessor.processMapping(request, response, (String)portlet.getInitParams().get("view-action"));

			ComponentDefinition definition = null;

			if (actionMapping != null) {

				// See action path /weather/view

				String definitionName = actionMapping.getForward();

				if (definitionName == null) {

					// See action path /journal/view_articles

					String[] definitionNames = actionMapping.findForwards();

					for (int definitionNamesPos = 0; definitionNamesPos < definitionNames.length; definitionNamesPos++) {
						if (definitionNames[definitionNamesPos].endsWith("view")) {
							definitionName = definitionNames[definitionNamesPos];

							break;
						}
					}

					if (definitionName == null) {
						definitionName = definitionNames[0];
					}
				}

				definition = TilesUtil.getDefinition(definitionName, request, application);
			}

			String templatePath = Constants.TEXT_HTML_DIR + "/portal/layout_portal.jsp";
			if (definition != null) {
				templatePath = Constants.TEXT_HTML_DIR + definition.getPath();
			}
	%>
		
<%@page import="com.dotmarketing.business.APILocator"%><jsp:include page="/html/portal/portlet_error.jsp"></jsp:include>
	<%
		}
		else {

				pageContext.getOut().print(stringServletRes.getString());

		}
	}
	else {
		renderRequest.setAttribute(WebKeys.PORTLET_CONTENT, stringServletRes.getString());

		String portletContent = StringPool.BLANK;
		if (portletException) {
			portletContent = "/portal/portlet_error.jsp";
		}
		
		
if(!statePopUp || portletException){%>
	<jsp:include page="/html/portal/portlet_error.jsp"></jsp:include>
<%}else{ %>
	<%= renderRequest.getAttribute(WebKeys.PORTLET_CONTENT) %>
<%}}%>




<script type="text/javascript">
	var shown=false;
	function showHelp() {
		var helpUrl = "//dotcms.com/inline-help/2.0/<%=portlet.getPortletId() %>";
        require(["dojo/_base/fx", "dojo/dom", "dojo/window", "dojo/dom-construct","dojo/dom-style"], function(baseFx, dom, win, cons, dstyle) {
        	var vp=win.getBox(win.doc);
        	if(!shown) {
        	    shown=true;
        		cons.create("iframe",{id:"helpiframe",src:helpUrl,width:'600', height:vp.h-60, style:'border: 0 none;' },"helpcontent");
	        	baseFx.animateProperty({
	                node: dom.byId("helpId"),
	                duration: 600,
	                properties: { top: {start:vp.h-30,end:20 } }
	            }).play();
        	}
        	else {
        		shown=false;
        		baseFx.animateProperty({
                    node: dom.byId("helpId"),
                    duration: 600,
                    onEnd:function() {
                        cons.destroy('helpiframe');
                        dstyle.set(dom.byId('helpId'),"top","");
                        dstyle.set(dom.byId('helpId'),"bottom","-1px");
                    },
                    properties: { top: {end:vp.h-30,start:20 } }
                }).play();
        		
        	}
        });
	}
	
</script>

<%if(request.getParameter("in_frame")==null){%>

<div class="helpId" id="helpId">
	<a href="#" onclick="showHelp();" class="dotcmsHelpButton"><%=LanguageUtil.get(pageContext, "help") %></a>
	<div id="helpcontent"></div>
</div>
<%} %>

