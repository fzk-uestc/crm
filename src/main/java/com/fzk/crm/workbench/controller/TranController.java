package com.fzk.crm.workbench.controller;

import com.fzk.crm.settings.domain.User;
import com.fzk.crm.settings.service.IUserService;
import com.fzk.crm.utils.DateTimeUtil;
import com.fzk.crm.utils.PrintJson;
import com.fzk.crm.utils.UUIDUtil;
import com.fzk.crm.vo.PaginationVO;
import com.fzk.crm.workbench.domain.Activity;
import com.fzk.crm.workbench.domain.Contacts;
import com.fzk.crm.workbench.domain.Tran;
import com.fzk.crm.workbench.domain.TranHistory;
import com.fzk.crm.workbench.service.ICustomerService;
import com.fzk.crm.workbench.service.ITranService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

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
 * @create 2021-03-14 12:37
 */
@Controller(value = "tranController")
@RequestMapping(path = "/workbench/transaction")
public class TranController extends HttpServlet {
    @Autowired
    private IUserService userService;
    @Autowired
    private ITranService tranService;
    @Autowired
    private ICustomerService customerService;

    @RequestMapping(path = "/addTran.do")
    private void addTran(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
//        IUserService userService = (IUserService) ServiceFactory.getService(new UserServiceImpl());
        List<User> userList = userService.getUserList();

        request.setAttribute("userList", userList);
        //请求转发
        request.getRequestDispatcher("/workbench/transaction/save.jsp").forward(request, response);
    }

    @RequestMapping(path = "/getActivityListByName.do")
    private void getActivityListByName(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数activityName
        String activityName = request.getParameter("activityName");
        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        List<Activity> activityList = tranService.getActivityListByName(activityName);
        //返回json
        PrintJson.printJsonObj(response, activityList);
    }

    @RequestMapping(path = "/getContactsListByName.do")
    private void getContactsListByName(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数contactsName
        String contactsName = request.getParameter("contactsName");
        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        List<Contacts> contactsList = tranService.getContactsListByName(contactsName);
        //返回json
        PrintJson.printJsonObj(response, contactsList);
    }

    @RequestMapping(path = "/getCustomerNameList.do")
    private void getCustomerNameList(HttpServletRequest request, HttpServletResponse response) {
        //取出插件传来的参数
        String customerName = request.getParameter("name");
        //调用业务层
//        ICustomerService customerService = (ICustomerService) ServiceFactory.getService(new CustomerServiceImpl());
        List<String> customerNameList = customerService.getCustomerNameList(customerName);
        //返回json
        PrintJson.printJsonObj(response, customerNameList);
    }

    @RequestMapping(path = "/saveTran.do")
    private void saveTran(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String id = UUIDUtil.getUUID();
        String createTime = DateTimeUtil.getSysTime();
        String createBy = ((User) request.getSession().getAttribute("user")).getName();
        //取出form表单传来的参数
        String owner = request.getParameter("owner");
        String money = request.getParameter("money");
        String name = request.getParameter("name");
        String expectedDate = request.getParameter("expectedDate");
        //注意这里取得的是customerName，需要在业务层判断是否存在该客户
        String customerName = request.getParameter("customerName");
        String stage = request.getParameter("stage");
        String type = request.getParameter("type");
        String source = request.getParameter("source");
        String activityId = request.getParameter("activityId");
        String contactsId = request.getParameter("contactsId");
        String description = request.getParameter("description");
        String contactSummary = request.getParameter("contactSummary");
        String nextContactTime = request.getParameter("nextContactTime");

        Tran tran = new Tran();

        tran.setId(id);
        tran.setOwner(owner);
        tran.setMoney(money);
        tran.setName(name);
        tran.setExpectedDate(expectedDate);
        tran.setStage(stage);
        tran.setType(type);
        tran.setSource(source);
        tran.setActivityId(activityId);
        tran.setContactsId(contactsId);
        tran.setCreateBy(createBy);
        tran.setCreateTime(createTime);
        tran.setDescription(description);
        tran.setContactSummary(contactSummary);
        tran.setNextContactTime(nextContactTime);

        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.saveTran(tran, customerName);
        if (flag) {
            //重定向到index.jsp
            response.sendRedirect(request.getContextPath() + "/workbench/transaction/index.jsp");
        }
    }

    @RequestMapping(path = "/detail.do")
    private void detail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //取出前端参数tranId
        String tranId = request.getParameter("tranId");
        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        Tran tran = tranService.detail(tranId);

        /*
        处理可能性possibility
        阶段stage
         */
        String stage = tran.getStage();
        Map<String, String> stageMap = (Map<String, String>) request.getServletContext().getAttribute("stageMap");
        String possibility = stageMap.get(stage);
        request.setAttribute("possibility", possibility);
        //将tran保存到detail.jsp的request域对象
        request.setAttribute("tran", tran);
        //请求转发
        request.getRequestDispatcher("/workbench/transaction/detail.jsp").forward(request, response);
    }

    @RequestMapping(path = "/getTranHistoryListByTranId.do")
    private void getTranHistoryListByTranId(HttpServletRequest request, HttpServletResponse response) {
        String tranId = request.getParameter("tranId");
        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        List<TranHistory> tranHistoryList = tranService.getTranHistoryListByTranId(tranId);
        //返回json
        PrintJson.printJsonObj(response, tranHistoryList);
    }

    @RequestMapping(path = "/changeStage.do")
    private void changeStage(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数,tranId,stage,money,expectedDate
        String tranId = request.getParameter("tranId");
        String stage = request.getParameter("stage");
        String money = request.getParameter("money");
        String expectedDate = request.getParameter("expectedDate");
        System.out.println(tranId);
        //修改人和修改时间
        String editBy = ((User) request.getSession().getAttribute("user")).getName();
        String editTime = DateTimeUtil.getSysTime();

        Tran tran = new Tran();
        tran.setId(tranId);
        tran.setStage(stage);
        tran.setMoney(money);
        tran.setExpectedDate(expectedDate);
        tran.setEditBy(editBy);
        tran.setEditTime(editTime);

        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        boolean flag = tranService.changeStage(tran);

        Map<String, Object> map = new HashMap<>();
        map.put("success", flag);
        map.put("tran", tran);
        //返回json
        PrintJson.printJsonObj(response, map);
    }

    @RequestMapping(path = "/pageList.do")
    private void pageList(HttpServletRequest request, HttpServletResponse response) {
        //取出前端参数
        String pageNoStr = request.getParameter("pageNo");
        String pageSizeStr = request.getParameter("pageSize");
        String owner = request.getParameter("owner");
        String name = request.getParameter("name");
        String customerName = request.getParameter("customerName");
        String stage = request.getParameter("stage");
        String type = request.getParameter("transactionType");
        String source = request.getParameter("source");
        String contactsName = request.getParameter("contactsName");

        int pageNo = Integer.valueOf(pageNoStr, 10);//展示的页数,转换为10进制
        int pageSize = Integer.valueOf(pageSizeStr, 10);//每页的列表条目数量
        //计算分页查询起始索引
        int index = (pageNo - 1) * pageSize;

        Map<String, Object> map = new HashMap<>();
        map.put("index", index);
        map.put("pageSize", pageSize);
        map.put("owner", owner);
        map.put("name", name);
        map.put("customerName", customerName);
        map.put("stage", stage);
        map.put("type", type);
        map.put("source", source);
        map.put("contactsName", contactsName);
        System.out.println(map);


        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        /*
        data
            {"total":100,"dataList":[{线索1},{2},{3}...]}

            PaginationVO
         */
        PaginationVO<Tran> vo = tranService.pageList(map);
        PrintJson.printJsonObj(response, vo);
    }

    @RequestMapping(path = "/getCharts.do")
    private void getCharts(HttpServletRequest request, HttpServletResponse response) {
        /*
        data
            {"total":10,"dataList":[{value: 60, name: '访问'},{},...]}
        */
        //调用业务层
//        ITranService tranService = (ITranService) ServiceFactory.getService(new TranServiceImpl());
        Map<String, Object> map = tranService.getCharts();
        //返回json
        PrintJson.printJsonObj(response, map);
    }

}
