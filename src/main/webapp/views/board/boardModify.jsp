<%--
  Created by IntelliJ IDEA.
  User: berno
  Date: 2020-05-20
  Time: 오전 2:05
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@include file="/views/common/htmlHead.jsp" %>
<html>
<head>
    <title>글수정:${boardListDetail.title}</title>
    <style>
        .btn-outline-light {
            color: #ffffff !important;
            border-color: #ffffff !important;
        }

        .btn-outline-light:hover {
            color: #212529 !important;
            background-color: #b9bbbe !important;
        }

        .table td span {
            /*font-family: 'Gothic A1', sans-serif;*/
            font-size: 0.813em;
            font-weight: 500;
            color: gray;
        }

        .table td a {
            /*font-family: 'Nanum Gothic', sans-serif;*/
            font-size: 0.938em;
            font-weight: 700;
            text-decoration: none;
            color: #4374D9;
        }

        /*div > input {*/
        /*    width: 100px;*/
        /*}*/

        .uploadResult {
            width: 100%;
            /*background-color: #c8cbcf;*/
        }

        .uploadResult ul {
            display: flex;
            flex-flow: column;
            justify-content: start;
            align-items: start;
        }

        .uploadResult ul li {
            list-style: none;
            padding: 10px;
            align-content: start;
            text-align: start;
        }

        .uploadResult ul li img {
            width: 100px;
        }

        .uploadResult ul li span {
            color: blue;
            font-weight: bold;
        }

        .bigPictureWrapper {
            position: absolute;
            display: none;
            justify-content: center;
            align-items: center;
            top: 0%;
            width: 100%;
            height: 100%;
            background-color: gray;
            z-index: 100;
            background: rgba(255, 255, 255, 0.5);
        }

        .bigPicture {
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        .bigPicture img {
            width: 600px;
        }
    </style>
    <script type="text/javascript">
        const boardId = ${boardListDetail.boardId};

        $(document).ready(function () {

            $("button").on("click", function (e) {

                e.preventDefault();

                let operation = $(this).data("oper");

                console.log(operation);

                if (operation === 'reset') {
                    $("#title").val(null);
                    $("#content").val(null);
                } else if (operation === 'modify') {
                    let title = $("#title").val();
                    let content = $("#content").val();
                    if (title == null || title === "") {
                        alert("제목을 입력해 주세요!");
                        $("#title").focus();
                        return false;
                    }

                    if (content == null || content === "") {
                        alert("내용을 입력해 주세요!");
                        $("#content").focus();
                        return false;
                    }
                    return modify_btn();

                } else if (operation === 'back') {
                    window.location.href = '/board/detail?id=' + boardId;
                }

            });

            // 업로드 파일 목록 가져오기
            (function () {
                $.getJSON("/board/getAttachList", {boardId: boardId}, function (arr) {

                    console.log(arr);

                    let str = "";


                    $(arr).each(function (i, attach) {

                        //image type
                        if (attach.fileType) {
                            let fileCallPath = encodeURIComponent(attach.uploadPath + "/s_" + attach.uuid + "_" + attach.fileName);

                            str += "<li data-path='" + attach.uploadPath + "' data-uuid='" + attach.uuid + "' data-filename='" + attach.fileName + "' data-type='" + attach.fileType + "' >";
                            str += "<div>";
                            str += "<span> " + attach.fileName + "</span>&nbsp;";
                            str += "<button type='button' data-file=\'" + fileCallPath + "\' data-type='image' class='btn btn-outline-light rounded-circle'><img id='cancel_img' src='/resources/images/x.svg'></button><br>";
                            str += "<img class='rounded' src='/board/display?fileName=" + fileCallPath + "'>";
                            str += "</div>";
                            str += "</li>";
                        } else {
                            let fileCallPath = encodeURIComponent(attach.uploadPath + "/" + attach.uuid + "_" + attach.fileName);

                            str += "<li data-path='" + attach.uploadPath + "' data-uuid='" + attach.uuid + "' data-filename='" + attach.fileName + "' data-type='" + attach.fileType + "' >";
                            str += "<div>";
                            str += "<span> " + attach.fileName + "</span>&nbsp;";
                            str += "<button type='button' data-file=\'" + fileCallPath + "\' data-type='file' class='btn btn-outline-light rounded-circle'><img id='cancel_img' src='/resources/images/x.svg'></button><br>";
                            str += "<img src='/resources/images/attach.png'></a>";
                            str += "</div>";
                            str += "</li>";
                        }
                    });


                    $(".uploadResult ul").html(str);

                });//end getjson
            })();//end function

            // 브라우저에서만 파일 삭제('x'버튼)
            $(".uploadResult").on("click", "button", function (e) {

                console.log("delete file");

                if (confirm("해당 파일을 삭제하시겠습니까? ")) {

                    let targetLi = $(this).closest("li");
                    targetLi.remove();
                }
            });

            // 업로드 파일 확장자, 파일크기 체크
            let regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$"); // 정규 표현식(regex)
            let maxSize = 225443840; //215MB

            function checkExtension(fileName, fileSize) {

                if (fileSize >= maxSize) {
                    alert("파일 사이즈 초과");
                    return false;
                }

                if (regex.test(fileName)) {
                    alert("해당 종류의 파일은 업로드할 수 없습니다.");
                    return false;
                }
                return true;
            }

            $("input[type='file']").change(function (e) {

                let formData = new FormData();

                let inputFile = $("input[name='uploadFile']");

                let files = inputFile[0].files;

                for (let i = 0; i < files.length; i++) {

                    if (!checkExtension(files[i].name, files[i].size)) {
                        return false;
                    }
                    formData.append("uploadFile", files[i]);

                }

                $.ajax({
                    url: '/board/uploadAjaxAct',
                    processData: false,
                    contentType: false,
                    data: formData,
                    type: 'POST',
                    dataType: 'json',
                    success: function (result) {
                        console.log(result);
                        showUploadResult(result); //업로드 결과 처리 함수

                    }
                }); //$.ajax

            });

            function showUploadResult(uploadResultArr) {

                if (!uploadResultArr || uploadResultArr.length === 0) {
                    return;
                }

                let uploadUL = $(".uploadResult ul");

                let str = "";

                $(uploadResultArr).each(function (i, obj) {

                    if (obj.image) {
                        let fileCallPath = encodeURIComponent(obj.uploadPath + "/s_" + obj.uuid + "_" + obj.fileName);
                        str += "<li data-path='" + obj.uploadPath + "' data-uuid='" + obj.uuid + "' data-filename='" + obj.fileName + "' data-type='" + obj.image + "'>";
                        str += "<div>";
                        str += "<span> " + obj.fileName + "</span>&nbsp;";
                        str += "<button type='button' data-file=\'" + fileCallPath + "\' data-type='image' class='btn btn-outline-light rounded-circle'><img id='cancel_img' src='/resources/images/x.svg'></button><br />";
                        str += "<img class='rounded' src='/board/display?fileName=" + fileCallPath + "'>";
                        str += "</div>";
                        str += "</li>";
                    } else {
                        let fileCallPath = encodeURIComponent(obj.uploadPath + "/" + obj.uuid + "_" + obj.fileName);
                        let fileLink = fileCallPath.replace(new RegExp(/\\/g), "/");

                        str += "<li data-path='" + obj.uploadPath + "' data-uuid='" + obj.uuid + "' data-filename='" + obj.fileName + "' data-type='" + obj.image + "' >"
                        str += "<div>";
                        str += "<span> " + obj.fileName + "</span>&nbsp;";
                        str += "<button type='button' data-file=\'" + fileCallPath + "\' data-type='file' class='btn btn-outline-light rounded-circle'><img id='cancel_img' src='/resources/images/x.svg'></button><br />";
                        str += "<img src='/resources/images/attach.png'></a>";
                        str += "</div>";
                        str += "</li>";
                    }

                });

                uploadUL.append(str);
            }

        });

        function modify_btn() {
            // let form = $('#form')[0];
            let formObj = $("#form");

            let str = "";

            $(".uploadResult ul li").each(function (i, obj) {

                let jobj = $(obj);

                console.dir(jobj);
                console.log("-------------------------");
                console.log(jobj.data("filename"));

                str += "<input type='hidden' name='attachList[" + i + "].fileName' value='" + jobj.data("filename") + "'>";
                str += "<input type='hidden' name='attachList[" + i + "].uuid' value='" + jobj.data("uuid") + "'>";
                str += "<input type='hidden' name='attachList[" + i + "].uploadPath' value='" + jobj.data("path") + "'>";
                str += "<input type='hidden' name='attachList[" + i + "].fileType' value='" + jobj.data("type") + "'>";

            });

            formObj.append(str);

            let data = new FormData(formObj[0]);

            console.log("Insert Request Data:", data);

            $.ajax({
                type: 'POST',
                url: '/board/modify',
                data: data,
                processData: false,
                contentType: false,
                // cache: false,
                // timeout: 600000,
                success: function (response) {
                    console.log("Modify Response Data:", response);
                    if (response.resCode === 602) {
                        alert(response.resMsg);
                        location.replace('/board/detail?id=' + boardId);
                    } else if (response.resCode === 603) {
                        alert(response.resMsg);
                    } else if (response.resCode === 607) {
                        alert(response.resMsg);
                    }
                },
                error: function (xhr, e, response) {
                    console.log("Insert Error:", xhr, e, response);
                    alert("에러!!")
                }
            });
        }

        // 글 입력 시 카운트
        function fnCheckByte(obj) {
            let maxByte = 100; // 최대 입력 바이트 수
            let str = obj.value;
            console.log("obj ", obj.value)
            let str_len = str.length;

            console.log("length: ", str)
            console.log("length: ", str_len)


            let rbyte = 0;
            let rlen = 0;
            let one_char = "";
            let str2 = "";

            for (let i = 0; i < str_len; i++) {
                one_char = str.charAt(i);

                if (escape(one_char).length > 4) {
                    rbyte += 2; // 한글 2byte
                } else {
                    rbyte++; // 영문 등 나머지 1byte
                }

                if (rbyte <= maxByte) {
                    rlen = i + 1; //return할 문자열 갯수
                }
            }

            if (rbyte > maxByte) {
                alert("한글 " + (maxByte / 2) + "자 / 영문 & 특수문자 " + maxByte + " 자를 초과 입력할 수 없습니다.");
                str2 = str.substr(0, rlen); // 문자열 자르기
                obj.value = str2;
                fnCheckByte(obj, maxByte);
            } else {
                $("#byteInfo").text(rbyte);
            }
        }

    </script>
</head>
<body class="body">

<%-- 헤더 --%>
<jsp:include page="/views/common/header.jsp"/>
<%-- security 계정 정보 --%>
<sec:authentication property="principal" var="userInfo"/>
<%-- //security 계정 정보 --%>

<%-- 바디 --%>
<section>
    <div class="container mt-5">
        <h3 class="text-center">글수정</h3>
        <%--        <form id="form" action="${pageContext.request.contextPath}/board/modify" method="post">--%>
        <form id="form">
            <input type="hidden" name="boardId" value="${boardListDetail.boardId}">
            <input type="hidden" value="${userInfo.accountId}" name="accountId">
            <input type="hidden" value="${userInfo.accountUserNm}" name="writer">
            <table class="table table-bordered">
                <tr class="thead-light">
                    <th class="tcenter">
                        <label for="title">제목</label>
                    </th>
                    <td>
                        <input type="text" id="title" name="title" class="form-control" placeholder="40자 이내  작성하세요"
                               value="${boardListDetail.title}"/>
                    </td>
                </tr>
                <tr class="thead-light">
                    <th class="tcenter">
                        <label for="content">내용</label>
                    </th>
                    <td>
                    <textarea id="content" name="content" rows="8" class="form-control w-100 mb-1"
                              onkeyup="fnCheckByte(this)"
                              placeholder="내용을 입력하세요...">${boardListDetail.content}</textarea>

                        <div class="d-inline ">
                            <span id="byteInfo" class="font-weight-bold">0</span>&nbsp;<span class="font-weight-bold">bytes</span>
                            &nbsp;&nbsp;<span style="font-weight: lighter;"> ※ 최대 입력 가능 글자수 100 byte </span>
                        </div>
                    </td>
                </tr>
                <c:if test="${userInfo.accountId == 1}">
                    <tr class="thead-light">
                        <th class="tcenter ">
                            <label for="boardType">공지여부</label>
                        </th>
                        <td>
                            <c:choose>
                                <c:when test="${boardListDetail.boardType eq 'N'}">
                                    공지사항: <input type="checkbox" id="boardType" name="boardType" value="N" checked>
                                </c:when>
                                <c:otherwise>
                                    공지사항: <input type="checkbox" id="boardType" name="boardType" value="N">
                                </c:otherwise>
                            </c:choose>

                        </td>
                    </tr>
                </c:if>
                <tr class="thead-light">
                    <th class="tcenter">
                        <label for="file">첨부파일</label>
                    </th>
                    <td align="left">
                        <div class="uploadDiv">
                            <input type="file" id="file" name="uploadFile" multiple/>
                            <span class="date">&nbsp;&nbsp;※&nbsp;jpg, png, zip, hwp, docx, pdf 확장자만 첨부 가능 </span>
                        </div>
                        <div class="uploadResult">
                            <ul></ul>
                        </div>
                    </td>
                </tr>

            </table>
            <br/>
            <div class="row justify-content-center">
                <button type="button" data-oper="reset" class="btn btn-outline-secondary" id="reset_btn">초기화</button>
                <button type="button" data-oper="modify" class="btn btn-outline-secondary mx-1" id="modify_btn">수정
                </button>
                <button type="button" data-oper="back" class="btn btn-outline-secondary" id="back_btn">취소</button>
            </div>
        </form>
    </div>
</section>
<div class='bigPictureWrapper'>
    <div class='bigPicture'>
    </div>
</div>
<%-- 푸터 --%>
<jsp:include page="/views/common/footer.jsp"/>
</body>
</html>
