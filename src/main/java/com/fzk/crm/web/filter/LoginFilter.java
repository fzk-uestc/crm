package com.fzk.crm.web.filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * @author fzkstart
 * @create 2021-02-24 17:27
 */
public class LoginFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        System.out.println("进入到登录验证的过滤器");

        //验证session中有没有user对象
        //ServletRequest中没有session对象，所以强转为其子接口
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;

        //注意：这里必须验证是不是登录页面，不然会循环进入这个过滤器
        String servletPath = request.getServletPath();
        System.out.println(servletPath);
        if ("/login.jsp".equals(servletPath) || "/settings/user/login.do".equals(servletPath)) {
            //登录页面，放行
            System.out.println("放行！");
            filterChain.doFilter(servletRequest, servletResponse);
        } else {
            Object user = request.getSession().getAttribute("user");
            if (user == null) {
                //说明没有登录过，重定向到登录页
                /*为什么这里使用重定向？
                    转发之后，路劲停留在老路径上，而不是跳转之后的新资源路劲

                */
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            } else {
                //说明登录过，放行
                filterChain.doFilter(servletRequest, servletResponse);
            }
        }
    }

    @Override
    public void destroy() {

    }
}
