import com.fzk.crm.exception.LoginException;
import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.settings.service.impl.UserServiceImpl;
import com.fzk.crm.utils.DateTimeUtil;
import com.fzk.crm.utils.MD5Util;
import com.fzk.crm.utils.ServiceFactory;
import com.fzk.crm.workbench.domain.Activity;
import org.junit.Test;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * @author fzkstart
 * @create 2021-02-22 13:34
 */
public class test1 {
    @Test
    public void test1() {
        String md5 = MD5Util.getMD5("010326");
        System.out.println(md5);
    }

    @Test
    public void test2() throws LoginException {
        IUserService loginService = (IUserService) ServiceFactory.getService(new UserServiceImpl());
        User user = loginService.login("ls", "202cb962ac59075b964b07152d234b70", "192.168.1.1");

        System.out.println(user);
    }

    @Test
    public void test3() throws NoSuchMethodException, IllegalAccessException, InstantiationException, InvocationTargetException {
        Class<Activity> clazz = Activity.class;
        Activity activity = clazz.newInstance();
        String name = clazz.getName();
        System.out.println("name=" + name);
        ClassLoader classLoader = clazz.getClassLoader();
        ClassLoader classLoaderParent = classLoader.getParent();
        ClassLoader classLoaderParentParent = classLoaderParent.getParent();
        System.out.println("classLoader=" + classLoader);
        System.out.println("classLoaderParent=" + classLoaderParent);
        System.out.println("classLoaderParentParent=" + classLoaderParentParent);
        System.out.println(ClassLoader.getSystemClassLoader());

    }
    @Test
    public void test4() throws NoSuchFieldException, IllegalAccessException {
        Class cache=Integer.class.getDeclaredClasses()[0];
        Field mycache = cache.getDeclaredField("cache");
        mycache.setAccessible(true);
        Integer[] newCache= (Integer[])mycache.get(cache);
        newCache[132]=newCache[133];
        int a=2;
        int b=a+a;
        System.out.printf("%d + %d = %d",a,a,b);
    }
}
