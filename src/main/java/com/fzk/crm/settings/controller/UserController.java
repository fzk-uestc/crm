package com.fzk.crm.settings.controller;

import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.settings.service.impl.UserServiceImpl;
import com.fzk.crm.utils.MD5Util;
import com.fzk.crm.utils.PrintJson;
import com.fzk.crm.utils.ServiceFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;

/**
 * @author fzkstart
 * @create 2021-02-22 13:11
 */
@Controller(value = "userController")
@RequestMapping(path = "/settings/user")
public class UserController{
    @Autowired
    private IUserService userService;

    @RequestMapping("/login.do")
    public void login(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到验证登录方法");

        String loginAct = request.getParameter("loginAct");
        String loginPwd = request.getParameter("loginPwd");
        System.out.println("账户："+loginAct+",密码:"+loginPwd);
        //将密码的明文形式转换为MD5密文形式
        String loginPwdMD5 = MD5Util.getMD5(loginPwd);
        System.out.println("密码的密文形式："+loginPwdMD5);


        //接受浏览器端的ip地址
        String ip = request.getRemoteAddr();
        System.out.println("ip地址为：--------->" + ip);

        //抛异常形式验证是否登录成功
        try {
            User user = userService.login(loginAct, loginPwdMD5, ip);
            request.getSession().setAttribute("user", user);

            //执行到这里，代表登录成功
            //将json串发给前端
            PrintJson.printJsonFlag(response,true);
        } catch (Exception e) {
            //业务层出问题，程序将执行到这里，表示登录失败
            /*
                message
                    {"success":true/false,"msg":"哪里出错了"}
             */
            String msg=e.getMessage();

            HashMap<String, Object> map = new HashMap<>();
            map.put("success",false);
            map.put("msg",msg);

            PrintJson.printJsonObj(response,map);
        }
    }
}
