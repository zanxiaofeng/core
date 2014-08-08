package com.dotmarketing.portlets.roleadmin.action;

import com.dotcms.repackage.javax.portlet.PortletConfig;
import com.dotcms.repackage.javax.portlet.RenderRequest;
import com.dotcms.repackage.javax.portlet.RenderResponse;

import com.dotcms.repackage.org.apache.struts.action.ActionForm;
import com.dotcms.repackage.org.apache.struts.action.ActionForward;
import com.dotcms.repackage.org.apache.struts.action.ActionMapping;

import com.liferay.portal.struts.PortletAction;

public class ViewRolesAction extends PortletAction {

	@Override
	public ActionForward render(ActionMapping mapping, ActionForm form, PortletConfig config, RenderRequest req, RenderResponse res) throws Exception {
		return mapping.findForward("portlet.ext.roleadmin.view_roles");
	}

}
