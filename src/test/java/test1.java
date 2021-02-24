import com.fzk.crm.exception.LoginException;
import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.settings.service.impl.UserServiceImpl;
import com.fzk.crm.utils.DateTimeUtil;
import com.fzk.crm.utils.ServiceFactory;
import org.junit.Test;

/**
 * @author fzkstart
 * @create 2021-02-22 13:34
 */
public class test1 {
    @Test
    public void test1(){
        String sysTime = DateTimeUtil.getSysTime();
        System.out.println(sysTime);
    }

    @Test
    public void test2() throws LoginException {
        IUserService loginService = (IUserService) ServiceFactory.getService(new UserServiceImpl());
        User user = loginService.login("ls", "202cb962ac59075b964b07152d234b70", "192.168.1.1");

        System.out.println(user);
    }
}
