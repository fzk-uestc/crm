<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <base href="<%=basePath%>">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <%--分页插件：必须放在bootstrap.min.js插件引入的下面，要先加载bootstrap--%>
    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

    <script type="text/javascript">

        $(function () {

            //为全选复选框绑定单击事件
            $("#checkAll").click(function (){
                $("input[name='check']").prop("checked",this.checked);
            });
            //为每一个单选复选框动态绑定事件，因为是动态生成的，用on绑定
            //对于动态生成的元素，不能直接绑定，需要绑定其祖先元素，再用选择器选到子元素
            $("#tranBody").on("click","input[name='check']",function (){
                $("#checkAll").prop("checked",$("input[name='check']:checked").length===$("input[name='check']").length);
            });
            //默认展开第一页，每页两条记录
            pageList(1, 2);

            //入口3：为查询按钮绑定事件，触发pageList方法
            $("#searchBtn").click(function () {
                /*
                每次我们点击搜索的时候，应该将搜索框中的信息保存起来，保存到隐藏域之中
                 */
                $("#hidden-owner").val($.trim($("#search-owner").val()));
                $("#hidden-name").val($.trim($("#search-name").val()));
                $("#hidden-customerName").val($.trim($("#search-customerName").val()));
                $("#hidden-stage").val($.trim($("#search-stage").val()));
                $("#hidden-transactionType").val($.trim($("#search-transactionType").val()));
                $("#hidden-source").val($.trim($("#search-source").val()));
                $("#hidden-contactsName").val($.trim($("#search-contactsName").val()));
                pageList(1, $("#tranPage").bs_pagination('getOption', 'rowsPerPage'));
            });
        });

        function pageList(pageNo, pageSize) {

            //查询前，将隐藏域中保存的信息取出来赋值给7个查询条件框
            $("#search-owner").val($.trim($("#hidden-owner").val()));
            $("#search-name").val($.trim($("#hidden-name").val()));
            $("#search-customerName").val($.trim($("#hidden-customerName").val()));
            $("#search-stage").val($.trim($("#hidden-stage").val()));
            $("#search-transactionType").val($.trim($("#hidden-transactionType").val()));
            $("#search-source").val($.trim($("#hidden-source").val()));
            $("#search-contactsName").val($.trim($("#hidden-contactsName").val()));
            //发送ajax请求获取交易列表
            $.ajax({
                url: "workbench/transaction/pageList.do",
                data: {
                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "owner": $.trim($("#search-owner").val()),
                    "name": $.trim($("#search-name").val()),
                    "customerName": $.trim($("#search-customerName").val()),
                    "stage": $.trim($("#search-stage").val()),
                    "transactionType": $.trim($("#search-transactionType").val()),
                    "source": $.trim($("#search-source").val()),
                    "contactsName": $.trim($("#search-contactsName").val())
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    /*
                    data
                        {"total":100,"dataList":[{线索1},{2},{3}...]}
                     */

                    /*<tr>
                        <td><input type="checkbox"/></td>
                            <td><a style="text-decoration: none; cursor: pointer;"
                        onclick="window.location.href='workbench/transaction/detail.do?tranId=3c1bb35f020d4a268b247f951339a3de';">交易1</a></td>
                            <td>动力节点</td>
                            <td>谈判/复审</td>
                            <td>新业务</td>
                            <td>zhangsan</td>
                            <td>广告</td>
                            <td>李四</td>
                    </tr>*/
                    let html = "";
                    $.each(data.dataList, function (i, n) {
                        html += '<tr><td><input type="checkbox" name="check" value="' + n.id + '"/></td>';
                        html += '<td><a style="text-decoration: none; cursor: pointer;"';
                        html += ' onclick="window.location.href=\'workbench/transaction/detail.do?tranId=' + n.id + '\';">' + n.name + '</a></td>';
                        html += '<td>' + n.customerId + '</td>';
                        html += '<td>' + n.stage + '</td>';
                        html += '<td>' + n.type + '</td>';
                        html += '<td>' + n.owner + '</td>';
                        html += '<td>' + n.source + '</td>';
                        html += '<td>' + n.contactsId + '</td></tr>';
                    });
                    //显示交易列表
                    $("#tranBody").html(html);

                    //计算总页数
                    let totalPages = Math.ceil(data.total / pageSize);
                    //数据处理完毕之后，结合分页查询，对前端展现分页信息
                    $("#tranPage").bs_pagination({
                        currentPage: pageNo, // 页码
                        rowsPerPage: pageSize, // 每页显示的记录条数
                        maxRowsPerPage: 20, // 每页最多显示的记录条数
                        totalPages: totalPages, // 总页数
                        totalRows: data.total, // 总记录条数

                        visiblePageLinks: 3, // 显示几个卡片

                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,
                        showRowsDefaultInfo: true,

                        //入口4：这里要调用自己写的这个查询方法进行分页查询
                        onChangePage: function (event, data) {
                            pageList(data.currentPage, data.rowsPerPage);
                        }
                    });
                }
            });

        }

    </script>
</head>
<body>
<%--隐藏域：将查询条件保存在隐藏域中--%>
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-name"/>
<input type="hidden" id="hidden-customerName"/>
<input type="hidden" id="hidden-stage"/>
<input type="hidden" id="hidden-transactionType"/>
<input type="hidden" id="hidden-source"/>
<input type="hidden" id="hidden-contactsName"/>

<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>交易列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="search-owner">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="search-name">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">客户名称</div>
                        <input class="form-control" type="text" id="search-customerName">
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">阶段</div>
                        <select class="form-control" id="search-stage">
                            <option></option>
                            <c:forEach items="${stage}" var="i">
                                <option value="${i.value}">${i.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">类型</div>
                        <select class="form-control" id="search-transactionType">
                            <option></option>
                            <c:forEach items="${transactionType}" var="i">
                                <option value="${i.value}">${i.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">来源</div>
                        <select class="form-control" id="search-source">
                            <option></option>
                            <c:forEach items="${source}" var="i">
                                <option value="${i.value}">${i.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">联系人名称</div>
                        <input class="form-control" type="text" id="search-contactsName">
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="searchBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary"
                        onclick="window.location.href='workbench/transaction/addTran.do';"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default"
                        onclick="window.location.href='workbench/transaction/edit.jsp';"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>


        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll" name="checkAll"/></td>
                    <td>名称</td>
                    <td>客户名称</td>
                    <td>阶段</td>
                    <td>类型</td>
                    <td>所有者</td>
                    <td>来源</td>
                    <td>联系人名称</td>
                </tr>
                </thead>
                <tbody id="tranBody">
                <tr>
                    <td><input type="checkbox" name="check"/></td>
                    <td><a style="text-decoration: none; cursor: pointer;"
                           onclick="window.location.href='workbench/transaction/detail.do?tranId=3c1bb35f020d4a268b247f951339a3de';">交易1</a>
                    </td>
                    <td>动力节点</td>
                    <td>谈判/复审</td>
                    <td>新业务</td>
                    <td>zhangsan</td>
                    <td>广告</td>
                    <td>李四</td>
                </tr>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 20px;" id="tranPage">
            <%--<div>
                <button type="button" class="btn btn-default" style="cursor: default;">共<b>50</b>条记录</button>
            </div>
            <div class="btn-group" style="position: relative;top: -34px; left: 110px;">
                <button type="button" class="btn btn-default" style="cursor: default;">显示</button>
                <div class="btn-group">
                    <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                        10
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="#">20</a></li>
                        <li><a href="#">30</a></li>
                    </ul>
                </div>
                <button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
            </div>
            <div style="position: relative;top: -88px; left: 285px;">
                <nav>
                    <ul class="pagination">
                        <li class="disabled"><a href="#">首页</a></li>
                        <li class="disabled"><a href="#">上一页</a></li>
                        <li class="active"><a href="#">1</a></li>
                        <li><a href="#">2</a></li>
                        <li><a href="#">3</a></li>
                        <li><a href="#">4</a></li>
                        <li><a href="#">5</a></li>
                        <li><a href="#">下一页</a></li>
                        <li class="disabled"><a href="#">末页</a></li>
                    </ul>
                </nav>
            </div>--%>
        </div>

    </div>

</div>
</body>
</html>