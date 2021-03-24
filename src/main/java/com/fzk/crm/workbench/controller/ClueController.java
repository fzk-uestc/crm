package com.fzk.crm.workbench.controller;

import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.settings.service.impl.UserServiceImpl;
import com.fzk.crm.utils.DateTimeUtil;
import com.fzk.crm.utils.PrintJson;
import com.fzk.crm.utils.ServiceFactory;
import com.fzk.crm.utils.UUIDUtil;
import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.domain.*;
import com.fzk.crm.workbench.service.IActivityService;
import com.fzk.crm.workbench.service.IClueService;
import com.fzk.crm.workbench.service.impl.ActivityServiceImpl;
import com.fzk.crm.workbench.service.impl.ClueServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * @author fzkstart
 * @create 2021-02-22 13:11
 */
@Controller(value="clueController")
@RequestMapping(path="/workbench/clue")
public class ClueController extends HttpServlet {
    @Autowired
    private IUserService userService;
    @Autowired
    private IClueService clueService;
    @RequestMapping(path="/getUserList.do")
    private void getUserList(HttpServletRequest request, HttpServletResponse response) {
        List<User> uList = userService.getUserList();
        PrintJson.printJsonObj(response, uList);
    }
    @RequestMapping(path="/pageList.do")
    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        System.out.println("进入到ClueController的pageList()...");

        //取出前端参数
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String fullname = request.getParameter("fullname");
        String company = request.getParameter("company");
        String phone = request.getParameter("phone");
        String source = request.getParameter("source");
        String owner = request.getParameter("owner");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");

        int pageNo = Integer.valueOf(pageNoStr, 10);//展示的页数,转换为10进制
        int pageSize = Integer.valueOf(pageSizeStr, 10);//每页的列表条目数量
        //计算分页查询起始索引
        int index = (pageNo - 1) * pageSize;

        Map<String, Object> map = new HashMap<>();
        map.put("index", index);
        map.put("fullname", fullname);
        map.put("company", company);
        map.put("phone", phone);
        map.put("source", source);
        map.put("owner", owner);
        map.put("mphone", mphone);
        map.put("state", state);
        map.put("pageSize", pageSize);
        System.out.println(map);

        /*
            前端要的是：线索信息列表
                        查询的总条数
               业务层拿到这两条信息后，如何返回？
                map？
                vo？
                PaginationVO<T>
                    private int total;
                    private List<T> dataList

                PaginationVO<Clue> vo=new PaginationVo();
                vo.setTotal(total);
                vo.setDataList(dataList);

                PrintJSON vo --> json串
                {"total":100,"dataList":[{市场活动1},{2},{3}...]}
                将来分页查询每个模块都有，所以选择使用通用的VO，操作起来更方便
        */
        PaginationVO<Clue> vo = clueService.pageList(map);
        PrintJson.printJsonObj(response, vo);
    }
    @RequestMapping(path="/saveClue.do")
    private void saveClue(HttpServletRequest request, HttpServletResponse response) {
        //给clue生成id,createTime和createBy
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        //取出前端参数
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");


        Clue clue = new Clue();
        clue.setId(id);
        clue.setCreateTime(createTime);
        clue.setCreateBy(createBy);
        clue.setFullname(fullname);
        clue.setAppellation(appellation);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);

        boolean flag = clueService.saveClue(clue);
        //返回json
        PrintJson.printJsonFlag(response, flag);
    }
    @RequestMapping(path="/detail.do")
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //取出前端参数
        String clueId = request.getParameter("id");

        Clue clue = clueService.detail(clueId);

        request.setAttribute("clue", clue);
        //请求转发
        request.getRequestDispatcher("/workbench/clue/detail.jsp").forward(request, response);
    }

    @RequestMapping(path="/getActivityByClueId.do")
    private void getActivityByClueId(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数
        String clueId = request.getParameter("clueId");

        List<Activity> activityList = clueService.getActivityByClueId(clueId);

        //返回json
        PrintJson.printJsonObj(response, activityList);
    }
    @RequestMapping(path="/getRemarkListByClueId.do")
    private void getRemarkListByClueId(HttpServletRequest request,HttpServletResponse response){
        //取出前端参数
        String clueId = request.getParameter("clueId");

        List<ClueRemark> clueRemarkList=clueService.getRemarkListByClueId(clueId);

        //返回json
        PrintJson.printJsonObj(response,clueRemarkList);
    }
    @RequestMapping(path="/unbund.do")
    private void unbund(HttpServletRequest request, HttpServletResponse response) {
        //取出需要取消关联的relationId
        String relationId = request.getParameter("relationId");
        boolean flag = clueService.unbund(relationId);
        //返回json
        PrintJson.printJsonFlag(response, flag);
    }

    @RequestMapping(path="/getActivityListByNameAndNotRelationClueId.do")
    private void getActivityListByNameAndNotRelationClueId(HttpServletRequest request, HttpServletResponse response) {
        //取出clueId和activityName
        //根据市场活动名称模糊查询，并且没关联当前clueId的activity
        String activityName = request.getParameter("activityName");
        String clueId = request.getParameter("clueId");

        //保存到map中
        Map<String, String> map = new HashMap<>();
        map.put("activityName", activityName);
        map.put("clueId", clueId);
        List<Activity> list = clueService.getActivityByNameAndNotRelationClueId(map);

        //返回json
        PrintJson.printJsonObj(response, list);
    }
    @RequestMapping(path="/bund.do")
    private void bund(HttpServletRequest request, HttpServletResponse response) {
        //取出clueId和activityId
        String clueId = request.getParameter("clueId");
        String[] activityIds = request.getParameterValues("activityId");
        boolean flag = clueService.bund(clueId, activityIds);
        //返回json
        PrintJson.printJsonFlag(response, flag);
    }
    @RequestMapping(path="/getUserListAndClue.do")
    private void getUserListAndClue(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数clueId
        String clueId = request.getParameter("clueId");
       /*
        data
            {"userList":[{1},{2},...],"clue":{clue}}
         */

        Map<String, Object> map = clueService.getUserListAndClue(clueId);
        //返回json
        PrintJson.printJsonObj(response, map);
    }
    @RequestMapping(path="/updateClue.do")
    private void updateClue(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数
        String id = request.getParameter("id");
        String fullname = request.getParameter("fullname");
        String appellation = request.getParameter("appellation");
        String owner = request.getParameter("owner");
        String company = request.getParameter("company");
        String job = request.getParameter("job");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String website = request.getParameter("website");
        String mphone = request.getParameter("mphone");
        String state = request.getParameter("state");
        String source = request.getParameter("source");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");
        String address = request.getParameter("address");
        //加上修改人和修改时间
        String editTime = DateTimeUtil.getSysTime();
        String editBy = ((User) request.getSession().getAttribute("user")).getName();

        //保存到clue中
        Clue clue = new Clue();
        clue.setId(id);
        clue.setFullname(fullname);
        clue.setAppellation(appellation);
        clue.setOwner(owner);
        clue.setCompany(company);
        clue.setJob(job);
        clue.setEmail(email);
        clue.setPhone(phone);
        clue.setWebsite(website);
        clue.setMphone(mphone);
        clue.setState(state);
        clue.setSource(source);
        clue.setDescription(description);
        clue.setContactSummary(contactSummary);
        clue.setNextContactTime(nextContactTime);
        clue.setAddress(address);
        clue.setEditTime(editTime);
        clue.setEditBy(editBy);

        boolean flag = clueService.updateClue(clue);
        //返回json
        PrintJson.printJsonFlag(response, flag);
    }
    @RequestMapping(path="/deleteClueByIds.do")
    private void deleteClueByIds(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数ids
        String[] ids = request.getParameterValues("id");

        boolean flag = clueService.deleteClueByIds(ids);
        //返回json
        PrintJson.printJsonFlag(response, flag);
    }
    @RequestMapping(path="/getActivityListByName.do")
    private void getActivityListByName(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数activityName
        String activityName = request.getParameter("activityName");

        List<Activity> activityList = clueService.getActivityListByName(activityName);
        //返回json
        PrintJson.printJsonObj(response, activityList);
    }
    @RequestMapping(path="/convert.do")
    private void convert(HttpServletRequest request, HttpServletResponse response) throws IOException {
        //取出前端参数clueId
        String clueId=request.getParameter("clueId");
        String createBy=((User)request.getSession().getAttribute("user")).getName();

        Tran tran=null;
        //判断发送的是get还是post请求
        if("GET".equals(request.getMethod())){
            //发送的get请求，说明不需要创建交易

        }else{
            //发送的post请求，说明需要创建交易
            tran=new Tran();

            //取出前端数据
            String money=request.getParameter("money");
            String tradeName= request.getParameter("tradeName");
            String expectedDate=request.getParameter("expectedDate");
            String stage=request.getParameter("stage");
            String activityId=request.getParameter("activityId");
            //新建tran的其他参数
            String id=UUIDUtil.getUUID();
            String createTime=DateTimeUtil.getSysTime();

            tran.setId(id);
            tran.setCreateTime(createTime);
            tran.setCreateBy(createBy);
            tran.setMoney(money);
            tran.setName(tradeName);
            tran.setExpectedDate(expectedDate);
            tran.setStage(stage);
            tran.setActivityId(activityId);
        }

        boolean flag=clueService.convert(tran,clueId,createBy);
        if(flag){
            response.sendRedirect(request.getContextPath()+"/workbench/clue/index.jsp");
        }
    }
    @RequestMapping(path="/getCharts.do")
    private void getCharts(HttpServletRequest request,HttpServletResponse response){
        /*
        data
            {"total":10,"dataList":[{value: 60, name: '访问'},{},...]}
        */

        Map<String,Object> map=clueService.getCharts();
        //返回json
        PrintJson.printJsonObj(response,map);
    }
}
