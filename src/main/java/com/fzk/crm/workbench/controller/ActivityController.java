package com.fzk.crm.workbench.controller;

import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.settings.service.impl.UserServiceImpl;
import com.fzk.crm.utils.*;
import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.domain.ActivityRemark;
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
        } else if ("/workbench/activity/getUserListAndActivity.do".equals(path)) {
            getUserListAndActivity(request, response);
        } else if ("/workbench/activity/updateActivity.do".equals(path)) {
            updateActivity(request, response);
        } else if ("/workbench/activity/detail.do".equals(path)) {
            detail(request, response);
        } else if ("/workbench/activity/getRemarkListByActivityId.do".equals(path)) {
            getRemarkListByActivityId(request, response);
        } else if ("/workbench/activity/deleteRemark.do".equals(path)) {
            deleteRemark(request, response);
        } else if ("/workbench/activity/saveRemark.do".equals(path)) {
            saveRemark(request, response);
        } else if ("/workbench/activity/updateRemark.do".equals(path)) {
            updateRemark(request, response);
        }
    }

    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
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
        for (String id : ids) {
            System.out.println(id);
        }
        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());

        boolean flag = activityService.deleteActivity(ids);

        //返回json串
        PrintJson.printJsonFlag(response, flag);
    }

    private void getUserListAndActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的getUserListAndActivity()...");
        //取出要修改的市场活动的id
        String activityId = request.getParameter("id");

        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        /*
        总结：
            controller调用service方法，前端值要什么，service返回值就是什么
        userList
        activity
        这两项信息复用率不高，选map，而不选vo
         */
        Map<String, Object> map = activityService.getUserListAndActivity(activityId);

        //返回json
        PrintJson.printJsonObj(response, map);
    }

    private void updateActivity(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的updateActivity()...");

        //取出参数
        String id = request.getParameter("id");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String cost = request.getParameter("cost");
        String description = request.getParameter("description");
        //修改时间：当前系统时间
        String editTime = DateTimeUtil.getSysTime();
        //修改人：当前登录用户
        String editBy = ((User) request.getSession().getAttribute("user")).getName();

        //向service层传activity
        Activity activity = new Activity();
        activity.setId(id);
        activity.setOwner(owner);
        activity.setName(name);
        activity.setStartDate(startDate);
        activity.setEndDate(endDate);
        activity.setCost(cost);
        activity.setDescription(description);
        activity.setEditTime(editTime);
        activity.setEditBy(editBy);

        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        boolean flag = activityService.updateActivity(activity);

        //返回json
        PrintJson.printJsonFlag(response, flag);
    }

    private void detail(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        System.out.println("进入到ActivityController的detail()...");

        //取出activity.id
        String activityId = request.getParameter("id");
        /*
        前端这里需要跳转页面，那么就将查询到的activity保存在request域中，请求转发
         */
        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        Activity activity = activityService.detail(activityId);
        System.out.println(activity);
        request.setAttribute("activity", activity);
        // 请求转发
        request.getRequestDispatcher("/workbench/activity/detail.jsp").forward(request, response);
    }

    private void getRemarkListByActivityId(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的getRemarkListByActivityId()...");

        //取出参数
        String activityId = request.getParameter("activityId");

        /*
          data
               [{remark1},{2},{3}]
        */
        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        List<ActivityRemark> list = activityService.getRemarkListByActivityId(activityId);
        //返回json
        PrintJson.printJsonObj(response, list);
    }

    private void deleteRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的deleteRemark()...");

        //取前端参数remarkId
        String remarkId = request.getParameter("remarkId");

        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        boolean flag = activityService.deleteRemark(remarkId);

        //返回json串
        PrintJson.printJsonFlag(response, flag);
    }

    private void saveRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的saveRemark()...");

        //取出前端参数
        String noteContent=request.getParameter("noteContent");
        String activityId=request.getParameter("activityId");
        //备注的其他信息
        String remarkId = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy=((User)request.getSession().getAttribute("user")).getName();
        String editFlag="0";

        ActivityRemark activityRemark=new ActivityRemark();
        activityRemark.setId(remarkId);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setCreateBy(createBy);
        activityRemark.setCreateTime(createTime);
        activityRemark.setEditFlag(editFlag);
        activityRemark.setActivityId(activityId);

        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        boolean flag = activityService.saveRemark(activityRemark);

        //保存到map
        /*
        data
            {"success":true/false,"remark":{备注}}
         */
        Map<String,Object> map=new HashMap<>();
        map.put("success",flag);
        map.put("remark",activityRemark);
        //返回json
        PrintJson.printJsonObj(response,map);
    }


    private void updateRemark(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ActivityController的updateRemark()...");

        //取出前端参数remarkId和noteContent
        String remarkId=request.getParameter("remarkId");
        String noteContent=request.getParameter("noteContent");
        //修改时间、修改人、editFlag
        String editTime = DateTimeUtil.getSysTime();
        String editBy=((User)request.getSession().getAttribute("user")).getName();
        String editFlag="1";

        ActivityRemark activityRemark=new ActivityRemark();
        activityRemark.setId(remarkId);
        activityRemark.setNoteContent(noteContent);
        activityRemark.setEditTime(editTime);
        activityRemark.setEditBy(editBy);
        activityRemark.setEditFlag(editFlag);

        //调用业务层
        IActivityService activityService =
                (IActivityService) ServiceFactory.
                        getService(new ActivityServiceImpl());
        boolean flag = activityService.updateRemark(activityRemark);

        //保存到map
        /*
        data
            {"success":true/false,"remark":{备注}}
         */
        Map<String,Object> map=new HashMap<>();
        map.put("success",flag);
        map.put("remark",activityRemark);
        //返回json
        PrintJson.printJsonObj(response,map);
    }


}
