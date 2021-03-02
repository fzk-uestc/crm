package com.fzk.crm.workbench.controller;

import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.settings.service.impl.UserServiceImpl;
import com.fzk.crm.utils.*;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.service.IActivityService;
import com.fzk.crm.workbench.service.impl.ActivityServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * @author fzkstart
 * @create 2021-02-22 13:11
 */
public class ActivityController extends HttpServlet {
    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("进入到市场活动控制器");
        String path = request.getServletPath();

        if ("/workbench/activity/getUserList.do".equals(path)) {
            getUserList(request, response);
        } else if ("/workbench/activity/saveActivity.do".equals(path)) {
            saveActivity(request, response);
        }
    }


    private void getUserList(HttpServletRequest request, HttpServletResponse response) {

        System.out.println("进入到取得用户信息列表getUserList()...");
        IUserService userService = (IUserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> uList = userService.getUserList();
        PrintJson.printJsonObj(response, uList);
    }

    private void saveActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到controller保存市场活动saveActivity()...");

        String id= UUIDUtil.getUUID();
        String owner=request.getParameter("owner");
        String name=request.getParameter("name");
        String startDate=request.getParameter("startDate");
        String endDate=request.getParameter("endDate");
        String cost=request.getParameter("cost");
        String description=request.getParameter("description");
        //创建时间：当前系统时间
        String createTime=DateTimeUtil.getSysTime();
        //创建人：当前登录用户
        String createBy=((User)request.getSession().getAttribute("user")).getName();

        Activity activity=new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setCreateTime(createTime);
        activity.setCreateBy(createBy);

        System.out.println(activity);
        //调用业务层
        IActivityService activityService = (IActivityService) ServiceFactory.getService(new ActivityServiceImpl());
        boolean flag=activityService.saveActivity(activity);

        //返回json字符串
        PrintJson.printJsonFlag(response,flag);

    }
}
