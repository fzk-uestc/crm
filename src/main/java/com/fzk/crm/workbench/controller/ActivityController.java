package com.fzk.crm.workbench.controller;

import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.settings.service.impl.UserServiceImpl;
import com.fzk.crm.utils.*;
import com.fzk.crm.vo.PaginationVO;
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
import java.util.Map;

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
        } else if ("/workbench/activity/pageList.do".equals(path)) {
            pageList(request, response);
        } else if ("/workbench/activity/deleteActivity.do".equals(path)) {
            deleteActivity(request, response);
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

        String id = UUIDUtil.getUUID();
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        //创建时间：当前系统时间
        String createTime = DateTimeUtil.getSysTime();
        //创建人：当前登录用户
        String createBy = ((User) request.getSession().getAttribute("user")).getName();

        Activity activity = new Activity();
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
        boolean flag = activityService.saveActivity(activity);

        //返回json字符串
        PrintJson.printJsonFlag(response, flag);

    }

    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的pageList()...");

        String name = request.getParameter("name");
        String owner = request.getParameter("owner");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");

        int pageNo = Integer.valueOf(pageNoStr, 10);//展示的页数,转换为10进制
        int pageSize = Integer.valueOf(pageSizeStr, 10);//每页的列表条目数量

        //计算分页查询起始索引
        int index = (pageNo - 1) * pageSize;

        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("index", index);
        map.put("pageSize", pageSize);

        System.out.println(map);
        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        /*
            前端要的是：市场活动信息列表
                        查询的总条数
               业务层拿到这两条信息后，如何返回？
                map？
                vo？
                PaginationVO<T>
                    private int total;
                    private List<T> dataList

                PaginationVO<Activity> vo=new PaginationVo();
                vo.setTotal(total);
                vo.setDataList(dataList);

                PrintJSON vo --> json串
                {"total":100,"dataList":[{市场活动1},{2},{3}...]}
                将来分页查询每个模块都有，所以选择使用通用的VO，操作起来更方便
         */
        PaginationVO<Activity> vo = activityService.pageList(map);

        //返回json字符串
        PrintJson.printJsonObj(response, vo);
    }

    private void deleteActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的deleteActivity()...");

        //取出请求删除的id集合
        String[] ids = request.getParameterValues("id");
        for (String id:ids) {
            System.out.println(id);
        }
        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());

        boolean flag=activityService.deleteActivity(ids);

        //返回json串
        PrintJson.printJsonFlag(response,flag);
    }

}
