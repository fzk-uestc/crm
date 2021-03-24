package com.fzk.crm.web.listener;

import com.fzk.crm.settings.domain.DicValue;
import com.fzk.crm.settings.service.IDicService;
import com.fzk.crm.settings.service.impl.DicServiceImpl;
import com.fzk.crm.utils.ServiceFactory;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import javax.servlet.ServletContext;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import java.util.*;

/**
 * @author fzkstart
 * @create 2021-03-08 17:29
 */
public class SysInitListener implements ServletContextListener {
    /*
    方法中的参数 sce：
        该参数能够取得被监听的对象
     */
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("ServletContext对象创建了！");
        ServletContext servletContext = sce.getServletContext();
        //取出数据字典
        IDicService dicService =
                (IDicService) ServiceFactory.
                        getService(new DicServiceImpl());

        /*
        应该向业务层要按typeCode分类的7个list
         map<String,List<DicValue>>
         */
        Map<String, List<DicValue>> map = dicService.getAll();
        //将数据字段保存到ServletContext
        Set<String> keySet = map.keySet();
        for (String key : keySet) {
            servletContext.setAttribute(key, map.get(key));
        }

        //-------------------------------------------------
        /*数据字典处理完成后，处理Stage2Possibility.properties文件
            解析该文件，将properties解析后的键值对对应关系保存到map
         */

        Map<String,String> stageMap=new HashMap<>();
        //解析properties文件,注意：此时不能加上.properties后缀名
        ResourceBundle resourceBundle=ResourceBundle.getBundle("Stage2Possibility");
        Enumeration<String> keys = resourceBundle.getKeys();
        while(keys.hasMoreElements()){
            //阶段为key
            String key = keys.nextElement();
            //可能性为value
            String value = resourceBundle.getString(key);
            stageMap.put(key,value);
        }
        //将stageMap保存到服务器缓存
        servletContext.setAttribute("stageMap", stageMap);
    }
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("ServletContext对象销毁了！");
    }
}
