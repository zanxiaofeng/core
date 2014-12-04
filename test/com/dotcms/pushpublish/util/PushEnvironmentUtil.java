package com.dotcms.pushpublish.util;

import com.dotcms.publisher.endpoint.business.PublishingEndPointAPI;
import com.dotcms.publisher.environment.business.EnvironmentAPI;
import com.dotmarketing.business.APILocator;
import com.dotcms.publisher.environment.bean.Environment;
import com.dotmarketing.business.Role;
import com.dotmarketing.beans.Permission;
import java.util.ArrayList;
import java.util.List;
import com.dotmarketing.business.PermissionAPI;
import com.dotcms.publisher.endpoint.bean.PublishingEndPoint;
import com.dotmarketing.cms.factories.PublicEncryptionFactory;
import com.dotmarketing.util.Logger;
import com.liferay.portal.model.User;

/**
 * Created by Oscar Arrieta on 12/4/14.
 */
public class PushEnvironmentUtil {

    /**
     * Creates Sender Env for Push Publish Test.
     */
    public static boolean createPushPublishSender(String serverAddress, String serverPort){

        try{
            User user = APILocator.getUserAPI().getSystemUser();
            User adminUser = APILocator.getUserAPI().loadByUserByEmail( "admin@dotcms.com", user, false );

            //Generate Push Publish Dev Env.
            //Preparing the url in order to push content
            EnvironmentAPI environmentAPI = APILocator.getEnvironmentAPI();
            PublishingEndPointAPI publisherEndPointAPI = APILocator.getPublisherEndPointAPI();

            String publishEnvironmentName = "Publish Environment";

            if(environmentAPI.findEnvironmentByName(publishEnvironmentName) == null){
                Environment environment = new Environment();
                environment.setName( publishEnvironmentName );
                environment.setPushToAll( false );

                //Find the roles of the admin user
                Role role = APILocator.getRoleAPI().loadRoleByKey( adminUser.getUserId() );

                //Create the permissions for the environment
                List<Permission> permissions = new ArrayList<Permission>();
                Permission p = new Permission( environment.getId(), role.getId(), PermissionAPI.PERMISSION_USE );
                permissions.add( p );

                //Create a environment
                environmentAPI.saveEnvironment( environment, permissions );

                //Now we need to create the end point
                PublishingEndPoint endpoint = new PublishingEndPoint();
                endpoint.setServerName( new StringBuilder( "Publish Endpoint" ));
                endpoint.setAddress( serverAddress );
                endpoint.setPort( serverPort );
                endpoint.setProtocol( "http" );
                endpoint.setAuthKey( new StringBuilder( PublicEncryptionFactory.encryptString("1111") ) );
                endpoint.setEnabled( true );
                endpoint.setSending( false );
                endpoint.setGroupId( environment.getId() );

                //Save the endpoint.
                publisherEndPointAPI.saveEndPoint( endpoint );
            }
        } catch (Exception e) {
            Logger.error(PushEnvironmentUtil.class, "Error creating Push Publish Sender", e);
            return false;
        }
        //If everything goes OK we return true.
        return true;
    }

    /**
     * Creates Receiver Env for Push Publish Test.
     */
    public static boolean createPushPublishReceiver(String serverAddress, String serverPort){

        try{
            String publishEndPointName = "Publish Receiver End Point";

            PublishingEndPointAPI publisherEndPointAPI = APILocator.getPublisherEndPointAPI();

            if(publisherEndPointAPI.findEndPointByName(publishEndPointName) == null){
                //Create a receiving end point
                PublishingEndPoint receivingFromEndpoint = new PublishingEndPoint();
                receivingFromEndpoint.setServerName( new StringBuilder( publishEndPointName ));
                receivingFromEndpoint.setAddress( serverAddress );
                receivingFromEndpoint.setPort( serverPort );
                receivingFromEndpoint.setProtocol( "http" );
                receivingFromEndpoint.setAuthKey( new StringBuilder( PublicEncryptionFactory.encryptString("1111") ) );
                receivingFromEndpoint.setEnabled( true );
                receivingFromEndpoint.setSending( true );

                //Save the endpoint.
                publisherEndPointAPI.saveEndPoint( receivingFromEndpoint );
            }
        } catch (Exception e){
            Logger.error(PushEnvironmentUtil.class, "Error creating Push Publish Receiver", e);
            return false;
        }
        //If everything goes OK we return true.
        return true;
    }
}
