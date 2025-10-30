// filepath: src/main/webapp/WEB-INF/views/public/shop-chat-public.jsp

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"  uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<%-- Thiết lập Context Path --%>
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- Lấy thông tin User từ Session --%>
<%-- Thử lấy object user nếu dự án có set; fallback sang session attributes do LoginServlet set --%>
<c:set var="u" value="${not empty sessionScope.currentUser ? sessionScope.currentUser : sessionScope.user}" />
<c:set var="roleAttr" value="${sessionScope.role}" />
<c:set var="emailAttr" value="${sessionScope.email}" />

<%-- Xử lý nickname cho Chat --%>
<c:choose>
    <c:when test="${not empty u}">
        <%-- Lấy Role từ object User hoặc fallback từ session --%>
        <c:set var="rolePart" value="${empty u.role ? (empty roleAttr ? 'GUEST' : roleAttr) : u.role}" />

        <%-- Lấy Tên: ưu tiên firstname > fullName > tên trước @ của email > fallback 'user' --%>
        <c:set var="namePart"
               value="${not empty u.firstname
                      ? u.firstname
                      : (not empty u.fullName
                        ? u.fullName
                        : (not empty u.email
                          ? fn:substringBefore(u.email,'@')
                          : (not empty emailAttr ? fn:substringBefore(emailAttr,'@') : 'user')))}" />
    </c:when>
    <c:otherwise>
        <%-- Người dùng chưa đăng nhập: dùng session attributes hoặc fallback 'GUEST'/'user' --%>
        <c:set var="rolePart" value="${empty roleAttr ? 'GUEST' : roleAttr}" />
        <c:set var="namePart" value="${not empty emailAttr ? fn:substringBefore(emailAttr,'@') : 'user'}" />
    </c:otherwise>
</c:choose>

<%-- Nickname cuối cùng: ROLE_NAME --%>
<c:set var="nick" value="${rolePart}_${namePart}" />

<%--- Giao diện và Style ---%>
<style>
  #chatBox { height: 420px; overflow-y: auto; white-space: pre-wrap; }
  #chatBox > div { margin-bottom: 6px; }
</style>

<div class="container py-4">
  <h3 class="mb-3">💬 Phòng chat công khai của shop: <c:out value="${shop.shopName}" /></h3>

  <%-- Khung hiển thị tin nhắn --%>
  <div id="chatBox" class="border rounded bg-light p-3 mb-3"></div>

  <%-- Form nhập tin nhắn --%>
  <form id="chatForm" onsubmit="return false;" class="d-flex gap-2">
    <input id="msgInput" class="form-control" placeholder="Nhập tin nhắn…" />
    <button id="sendBtn" type="button" class="btn btn-primary">Gửi</button>
  </form>
</div>

<%--- Logic JavaScript cho WebSocket ---%>
<script>
(function () {
  const ctx    = '${ctx}';
  const shopId = '${param.shopId}';

  if (!shopId) {
    console.warn('Missing shopId');
    return;
  }

  // Escape XML để đảm bảo nickname an toàn khi đưa vào URL
  const nick = encodeURIComponent('${fn:escapeXml(nick)}');

  // Xây dựng URL WebSocket: thêm room=public để tách khỏi phòng nội bộ
  const wsUrl = (location.protocol === 'https:' ? 'wss://' : 'ws://')
              + location.host + ctx + '/ws/chat/' + shopId + '?room=public&nick=' + nick;

  // Lấy các phần tử DOM
  const box   = document.getElementById('chatBox');
  const input = document.getElementById('msgInput');
  const btn   = document.getElementById('sendBtn');

  // Hàm thêm tin nhắn vào chat box
  function append(t) {
    const d = document.createElement('div');
    d.textContent = t;
    box.appendChild(d);
    // Cuộn xuống cuối
    box.scrollTop = box.scrollHeight;
  }

  let ws;

  // Hàm kết nối WebSocket
  function connect() {
    ws = new WebSocket(wsUrl);
    ws.onopen    = () => append('🔌 Đã kết nối.');
    ws.onmessage = (e) => append(e.data);
    ws.onclose   = () => append('❌ Mất kết nối.');
    ws.onerror   = () => append('⚠️ Lỗi kết nối.');
  }

  // Sự kiện nút Gửi
  btn.addEventListener('click', () => {
    const t = (input.value || '').trim();
    // Kiểm tra tin nhắn, đối tượng ws và trạng thái kết nối (readyState 1: OPEN)
    if (!t || !ws || ws.readyState !== 1) return;

    ws.send(t);
    input.value = ''; // Xóa nội dung input sau khi gửi
  });

  // Sự kiện phím Enter trong input
  input.addEventListener('keydown', (e) => {
    // Nếu là phím Enter và không nhấn Shift, ngăn hành động mặc định và click nút Gửi
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      btn.click();
    }
  });

  // Khởi tạo kết nối khi tải trang
  connect();
})();
</script>