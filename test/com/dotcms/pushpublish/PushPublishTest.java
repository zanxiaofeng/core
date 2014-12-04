package com.dotcms.pushpublish;

import com.dotcms.LicenseTestUtil;
import com.dotcms.TestBase;
import com.dotcms.repackage.org.junit.Before;

/**
 * Created by Oscar Arrieta on 12/4/14.
 */
public class PushPublishTest extends TestBase {

    @Before
    public void prepare() throws Exception {
        LicenseTestUtil.getLicense();
    }
}
