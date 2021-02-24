package com.fzk.crm.web.filter;

import javax.servlet.*;
import java.io.IOException;

/**
 * @author fzkstart
 * @create 2021-02-24 16:27
 */
public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        System.out.println("进入到过滤中文编码的过滤器");

        //过滤post请求中文乱码参数
        servletRequest.setCharacterEncoding("utf-8");
        //过滤响应流响应中文乱码
        servletResponse.setContentType("text/html;charset=utf-8");

        //将请求放行
        filterChain.doFilter(servletRequest,servletResponse);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    @Override
    public void destroy() {

    }
}
