<%@ page contentType="text/html;charset=UTF-8" language="java" isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
    <%--分页插件：必须放在bootstrap.min.js插件引入的下面，要先加载bootstrap--%>
    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

    <script type="text/javascript">
        $(function () {
            //日历控件
            $(".time").datetimepicker({
                minView: "month",
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                aotuclose: true,
                todayBtn: true,
                pickerPosition: "top-left"
            });

            //为创建按钮绑定事件，打开创建线索的模态窗口
            $("#addBtn").click(function () {
                //先发送ajax请求，拿到所有者数据
                $.ajax({
                    url: "workbench/clue/getUserList.do",
                    type: "get",
                    dataType: "json",
                    success: function (data) {
                        /*
                        data
                            [{owner},{},{}]
                         */
                        let html = "";
                        $.each(data, function (i, user) {
                            html += "<option value='" + user.id + "'>" + user.name + "</option>";
                        });
                        $("#create-clueOwner").html(html);
                        //将当前登录的用户设置为下拉框默认选项
                        //注意：在js中使用el表达式，必须套在字符串中，不然会出错
                        $("#create-clueOwner").val("${user.id}");
                        /*
                        操作模态窗口的方式：
                            找到需要操作模态窗口的jQuery对象，
                            调用modal方法，传入show：打开 或  hide：关闭参数
                         */
                        $("#createClueModal").modal("show");
                    }
                });
            });

            //为保存按钮绑定事件，执行保存线索操作
            $("#saveBtn").click(function () {
                //先检查输入内容是否合法
                let fullname = $.trim($("#create-fullname").val());
                let appellation = $.trim($("#create-appellation").val());
                let owner = $.trim($("#create-clueOwner").val());
                let company = $.trim($("#create-company").val());
                let job = $.trim($("#create-job").val());
                let email = $.trim($("#create-email").val());
                let phone = $.trim($("#create-phone").val());
                let website = $.trim($("#create-website").val());
                let mphone = $.trim($("#create-mphone").val());
                let state = $.trim($("#create-state").val());
                let source = $.trim($("#create-source").val());
                let description = $.trim($("#create-description").val());
                let contactSummary = $.trim($("#create-contactSummary").val());
                let nextContactTime = $.trim($("#create-nextContactTime").val());
                let address = $.trim($("#create-address").val());
                //由于时间有限，这里假设输入都是合法的

                //发送ajax请求
                $.ajax({
                    url: "workbench/clue/saveClue.do",
                    data: {
                        "fullname": fullname,
                        "appellation": appellation,
                        "owner": owner,
                        "company": company,
                        "job": job,
                        "email": email,
                        "phone": phone,
                        "website": website,
                        "mphone": mphone,
                        "state": state,
                        "source": source,
                        "description": description,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime,
                        "address": address
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        /*
                        data
                            {"success":true/false}
                         */
                        if (data.success) {
                            //入口2.1：添加成功，局部刷新线索列表
                            //刷新列表操作类似于之前activity模块的那样操作
                            pageList(1, $("#cluePage").bs_pagination('getOption', 'rowsPerPage'));

                            //清空模态窗口中的内容
                            $("#create-fullname").val("");
                            $("#create-appellation").val("");
                            $("#create-clueOwner").val("");
                            $("#create-company").val("");
                            $("#create-job").val("");
                            $("#create-email").val("");
                            $("#create-phone").val("");
                            $("#create-website").val("");
                            $("#create-mphone").val("");
                            $("#create-state").val("");
                            $("#create-source").val("");
                            $("#create-description").val("");
                            $("#create-contactSummary").val("");
                            $("#create-nextContactTime").val("");
                            $("#create-address").val("");
                            //关闭模态窗口
                            $("#createClueModal").modal("hide");
                        } else {
                            alert("添加线索失败！");
                        }
                    }
                });
            });

            //入口1：页面加载完成后触发加载线索信息列表的方法
            //默认展开第一页，每页两条记录
            pageList(1, 2);

            //入口3：为查询按钮绑定事件，触发pageList方法
            $("#searchBtn").click(function () {
                /*
                每次我们点击搜索的时候，应该将搜索框中的信息保存起来，保存到隐藏域之中
                 */
                $("#hidden-fullname").val($.trim($("#search-fullname").val()));
                $("#hidden-company").val($.trim($("#search-company").val()));
                $("#hidden-phone").val($.trim($("#search-phone").val()));
                $("#hidden-source").val($.trim($("#search-source").val()));
                $("#hidden-owner").val($.trim($("#search-owner").val()));
                $("#hidden-mphone").val($.trim($("#search-mphone").val()));
                $("#hidden-state").val($.trim($("#search-state").val()));
                pageList(1, $("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
            });

            //为修改线索按钮绑定单击事件
            $("#editBtn").click(function () {
                let $checked = $("input[name='check']:checked");
                if ($checked.length === 0) {
                    alert("请选择要修改的线索！");
                } else if ($checked.length > 1) {
                    alert("一次只能修改一条记录！");
                } else {
                    //选中的clueId
                    let clueId = $checked.val();
                    $.ajax({
                        url: "workbench/clue/getUserListAndClue.do",
                        data: {
                            "clueId": clueId
                        },
                        dataType: "json",
                        type: "get",
                        success: function (data) {
                            /*
                            data
                                {"userList":[{1},{2},...],"clue":{clue}}
                             */
                            //处理所有者下拉框
                            let html = "";
                            $.each(data.userList, function (i, n) {
                                html += '<option value="' + n.id + '">' + n.name + '</option>'
                            });
                            $("#edit-clueOwner").html(html);
                            //处理单条clue
                            /*
                                id保存在修改线索模态窗口的隐藏域中
                             */
                            $("#edit-id").val(data.clue.id);
                            $("#edit-clueOwner").val(data.clue.owner);
                            $("#edit-fullname").val(data.clue.fullname);
                            $("#edit-appellation").val(data.clue.appellation);
                            $("#edit-company").val(data.clue.company);
                            $("#edit-job").val(data.clue.job);
                            $("#edit-email").val(data.clue.email);
                            $("#edit-phone").val(data.clue.phone);
                            $("#edit-website").val(data.clue.website);
                            $("#edit-mphone").val(data.clue.mphone);
                            $("#edit-state").val(data.clue.state);
                            $("#edit-source").val(data.clue.source);
                            $("#edit-description").val(data.clue.description);
                            $("#edit-contactSummary").val(data.clue.contactSummary);
                            $("#edit-nextContactTime").val(data.clue.nextContactTime);
                            $("#edit-address").val(data.clue.address);
                            //打开模态窗口
                            $("#editClueModal").modal("show");
                        }
                    });
                }
            });
            //为更新按钮绑定单击事件
            $("#updateBtn").click(function () {
                //先检查输入内容是否合法
                let fullname = $.trim($("#edit-fullname").val());
                let appellation = $.trim($("#edit-appellation").val());
                let owner = $.trim($("#edit-clueOwner").val());
                let company = $.trim($("#edit-company").val());
                let job = $.trim($("#edit-job").val());
                let email = $.trim($("#edit-email").val());
                let phone = $.trim($("#edit-phone").val());
                let website = $.trim($("#edit-website").val());
                let mphone = $.trim($("#edit-mphone").val());
                let state = $.trim($("#edit-state").val());
                let source = $.trim($("#edit-source").val());
                let description = $.trim($("#edit-description").val());
                let contactSummary = $.trim($("#edit-contactSummary").val());
                let nextContactTime = $.trim($("#edit-nextContactTime").val());
                let address = $.trim($("#edit-address").val());
                //由于时间有限，这里假设输入都是合法的
                $.ajax({
                    url: "workbench/clue/updateClue.do",
                    data: {
                        //将隐藏域中的clue.id也发过去
                        "id":$("#edit-id").val(),
                        "fullname": fullname,
                        "appellation": appellation,
                        "owner": owner,
                        "company": company,
                        "job": job,
                        "email": email,
                        "phone": phone,
                        "website": website,
                        "mphone": mphone,
                        "state": state,
                        "source": source,
                        "description": description,
                        "contactSummary": contactSummary,
                        "nextContactTime": nextContactTime,
                        "address": address
                    },
                    type: "post",
                    dataType: "json",
                    success: function (data) {
                        /*
                        data
                            {"success":true/false}
                         */
                        //回到修改前的页面和每页展示条数
                        if (data.success) {
                            pageList($("#cluePage").bs_pagination('getOption', 'currentPage'), $("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
                            //关闭模态窗口
                            $("#editClueModal").modal("hide");
                        }else{
                            alert("更新失败！");
                        }
                    }
                });
            });

            //为删除按钮绑定单击事件
            $("#deleteBtn").click(function (){
                //找到打√的的线索clue
                let $checked = $("input[name='check']:checked");
                if($checked.length===0){
                    alert("请选择需要删除的线索！");
                    return false;
                }
                if(!window.confirm("确认删除选中的线索吗？")){
                    return false;
                }
                //发送ajax请求，workbench/clue/deleteClueByIds.do?id=xxx&id=xxx
                let param="";
                $.each($checked,function (i,n){
                   if(i!==0){
                       param+="&id="+n.value;
                   } else{
                       param+="id="+n.value;
                   }
                });
                $.ajax({
                    url:"workbench/clue/deleteClueByIds.do",
                    data:param,
                    dataType:"json",
                    type:"post",
                    success:function (data){
                        /*
                        data
                            {"success":true/false}
                         */
                        if(data.success){
                            //删除成功后，局部刷新线索列表
                            pageList($("#cluePage").bs_pagination('getOption', 'currentPage'), $("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
                        }else{
                            alert("删除失败！");
                        }
                    }
                });
            });

            //为全选复选框绑定单击事件
            $("#checkAll").click(function (){
               $("input[name='check']").prop("checked",this.checked);
            });
            //为每一个单选复选框动态绑定事件，因为是动态生成的，用on绑定
            //对于动态生成的元素，不能直接绑定，需要绑定其祖先元素，再用选择器选到子元素
            $("#clueBody").on("click","input[name='check']",function (){
                $("#checkAll").prop("checked",$("input[name='check']:checked").length===$("input[name]").length);
            });
        });

        /*
            对于所有的关系型数据库，做前端的分页相关操作的基础组件
            就是pageNo和pageSize
            pageNo：页码
            pageSize：每页展示的记录数

            在下列情况下需要刷新列表：
                1. 点击左侧菜单中的“线索”超链接
                2. 添加，修改和删除后都需要刷新
                3. 点击查询按钮的时候
                4. 点击分页组件的时候
            以上6个入口都将要调用此方法
         */
        function pageList(pageNo, pageSize) {
            //将复选框的全选框的√取消
            $("#checkAll").prop("checked", false);

            //查询前，将隐藏域中保存的信息取出来赋值给7个查询条件框
            $("#search-fullname").val($.trim($("#hidden-fullname").val()));
            $("#search-company").val($.trim($("#hidden-company").val()));
            $("#search-phone").val($.trim($("#hidden-phone").val()));
            $("#search-source").val($.trim($("#hidden-source").val()));
            $("#search-owner").val($.trim($("#hidden-owner").val()));
            $("#search-mphone").val($.trim($("#hidden-mphone").val()));
            $("#search-state").val($.trim($("#hidden-state").val()));
            $.ajax({
                url: "workbench/clue/pageList.do",
                data: {
                    "pageNo": pageNo,
                    "pageSize": pageSize,
                    "fullname": $.trim($("#search-fullname").val()),
                    "company": $.trim($("#search-company").val()),
                    "phone": $.trim($("#search-phone").val()),
                    "source": $.trim($("#search-source").val()),
                    "owner": $.trim($("#search-owner").val()),
                    "mphone": $.trim($("#search-mphone").val()),
                    "state": $.trim($("#search-state").val())
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    /*
                    data    json串
                        我们需要的：
                        [{线索1},{2},{3}...] List<Clue> dataList
                        分页插件需要的：查询出来的总记录数
                        {"total":100}  int total

                        则json串
                        {"total":100,"dataList":[{线索1},{2},{3}...]}
                     */
                    let html = "";
                    $.each(data.dataList, function (i, n) {
                        <%--模板如下：
                       <tr class="active">
                            <td><input type="checkbox"/></td>
                            <td><a style="text-decoration: none; cursor: pointer;"
                                   onclick="window.location.href='workbench/clue/detail.do?id=285aa885120642dbaf31f5d85dbdb7d5';">陈翔先生</a></td>
                            <td>动力节点</td>
                            <td>010-84846003</td>
                            <td>12345678901</td>
                            <td>广告</td>
                            <td>zhangsan</td>
                            <td>已联系</td>
                        </tr>
                         --%>
                        html += '<tr class="active">';
                        html += '<td><input type="checkbox" name="check" value="' + n.id + '"/></td>';
                        html += '<td><a style="text-decoration: none; cursor: pointer;"';
                        html += ' onclick=\"window.location.href=\'workbench/clue/detail.do?id=' + n.id + '\';\">' + n.fullname + '</a></td>';
                        html += '<td>' + n.company + '</td>';
                        html += '<td>' + n.phone + '</td>';
                        html += '<td>' + n.mphone + '</td>';
                        html += '<td>' + n.source + '</td>';
                        html += '<td>' + n.owner + '</td>';
                        html += '<td>' + n.state + '</td>';
                        html += '</tr>';
                    });
                    //显示市场活动列表
                    $("#clueBody").html(html);

                    //计算总页数
                    let totalPages = Math.ceil(data.total / pageSize);
                    //数据处理完毕之后，结合分页查询，对前端展现分页信息
                    $("#cluePage").bs_pagination({
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
<input type="hidden" id="hidden-fullname"/>
<input type="hidden" id="hidden-company"/>
<input type="hidden" id="hidden-phone"/>
<input type="hidden" id="hidden-source"/>
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-mphone"/>
<input type="hidden" id="hidden-state"/>


<!-- 创建线索的模态窗口 -->
<div class="modal fade" id="createClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">创建线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="create-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-clueOwner">
                                <%--<option>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>--%>
                            </select>
                        </div>
                        <label for="create-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-company">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-appellation" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-appellation">
                                <option></option>
                                <c:forEach items="${appellation}" var="i">
                                    <option value="${i.value}">${i.text}</option>
                                </c:forEach>
                                <%--<option>先生</option>
                                <option>夫人</option>
                                <option>女士</option>
                                <option>博士</option>
                                <option>教授</option>--%>
                            </select>
                        </div>
                        <label for="create-fullname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-fullname">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-job">
                        </div>
                        <label for="create-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-email">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-phone">
                        </div>
                        <label for="create-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-website">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-mphone">
                        </div>
                        <label for="create-state" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-state">
                                <option></option>
                                <c:forEach items="${clueState}" var="i">
                                    <option value="${i.value}">${i.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-source">
                                <option></option>
                                <c:forEach items="${applicationScope.source}" var="i">
                                    <option value="${i.value}">${i.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>


                    <div class="form-group">
                        <label for="create-description" class="col-sm-2 control-label">线索描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-description"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="create-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="create-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" id="saveBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改线索的模态窗口 -->
<div class="modal fade" id="editClueModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 90%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title">修改线索</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <%--隐藏域：隐藏了clue.id，便于后续的更新操作--%>
                    <input type="hidden" id="edit-id">
                    <div class="form-group">
                        <label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-clueOwner">
                                <%--<option>zhangsan</option>
                                <option>lisi</option>
                                <option>wangwu</option>--%>
                            </select>
                        </div>
                        <label for="edit-company" class="col-sm-2 control-label">公司<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-company">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-call" class="col-sm-2 control-label">称呼</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-appellation">
                                <option></option>
                                <c:forEach items="${appellation}" var="i">
                                    <option value="${i.value}">${i.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-surname" class="col-sm-2 control-label">姓名<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-fullname">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-job" class="col-sm-2 control-label">职位</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-job">
                        </div>
                        <label for="edit-email" class="col-sm-2 control-label">邮箱</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-email">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone">
                        </div>
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-mphone" class="col-sm-2 control-label">手机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-mphone">
                        </div>
                        <label for="edit-state" class="col-sm-2 control-label">线索状态</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-state">
                                <option></option>
                                <c:forEach items="${clueState}" var="i">
                                    <option value="${i.value}">${i.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-source" class="col-sm-2 control-label">线索来源</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-source">
                                <option></option>
                                <c:forEach items="${applicationScope.source}" var="i">
                                    <option value="${i.value}">${i.text}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-description"></textarea>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

                    <div style="position: relative;top: 15px;">
                        <div class="form-group">
                            <label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-nextContactTime">
                            </div>
                        </div>
                    </div>

                    <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                    <div style="position: relative;top: 20px;">
                        <div class="form-group">
                            <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="1" id="edit-address"></textarea>
                            </div>
                        </div>
                    </div>
                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="updateBtn">更新</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>线索列表</h3>
        </div>
    </div>
</div>

<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">

    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="search-fullname">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司</div>
                        <input class="form-control" type="text" id="search-company">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">公司座机</div>
                        <input class="form-control" type="text" id="search-phone">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索来源</div>
                        <select class="form-control" id="search-source">
                            <option></option>
                            <c:forEach items="${applicationScope.source}" var="i">
                                <option value="${i.value}">${i.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <br>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="search-owner">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">手机</div>
                        <input class="form-control" type="text" id="search-mphone">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">线索状态</div>
                        <select class="form-control" id="search-state">
                            <option></option>
                            <c:forEach items="${applicationScope.clueState}" var="i">
                                <option value="${i.value}">${i.text}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="searchBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span>
                    创建
                </button>
                <button type="button" class="btn btn-default" id="editBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
            </div>


        </div>
        <div style="position: relative;top: 50px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>公司</td>
                    <td>公司座机</td>
                    <td>手机</td>
                    <td>线索来源</td>
                    <td>所有者</td>
                    <td>线索状态</td>
                </tr>
                </thead>
                <tbody id="clueBody">
                <%-- <tr class="active">
                     <td><input type="checkbox"/></td>
                     <td><a style="text-decoration: none; cursor: pointer;"
                            onclick="window.location.href='workbench/clue/detail.do?id=285aa885120642dbaf31f5d85dbdb7d5';">陈翔先生</a>
                     </td>
                     <td>动力节点</td>
                     <td>010-84846003</td>
                     <td>12345678901</td>
                     <td>广告</td>
                     <td>zhangsan</td>
                     <td>已联系</td>
                 </tr>--%>
                </tbody>
            </table>
        </div>

        <div style="height: 50px; position: relative;top: 60px;">
            <div id="cluePage"></div>
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