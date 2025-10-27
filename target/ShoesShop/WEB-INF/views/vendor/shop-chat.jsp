<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<%-- Lấy user trong session: đã sửa ở lần trước, biến u đã có giá trị --%>
<c:set var="u" value="${not empty sessionScope.currentUser ? sessionScope.currentUser : sessionScope.user}" />
<c:choose>
  <c:when test="${not empty u}">
    <c:set var="rolePart" value="${empty u.role ? 'USER' : u.role}" />
    <c:set var="namePart"
           value="${not empty u.firstname   
                   ? u.firstname           
                   : (not empty u.fullName
                       ? u.fullName
                       : (not empty u.email ? fn:substringBefore(u.email,'@') : 'guest'))}" />
    <c:set var="nick" value="${rolePart}_${namePart}" />
  </c:when>
  <c:otherwise>
    <c:set var="nick" value="GUEST_user" />
  </c:otherwise>
</c:choose>

<div class="container py-4">
  <h3 class="mb-3">💬 Phòng chat của shop: <c:out value="${shop.shopName}" /></h3>

  <div id="chatBox" class="border rounded bg-light p-3 mb-3"
       style="height: 420px; overflow-y: auto; white-space: pre-wrap;"></div>

  <form id="chatForm" onsubmit="return false;" class="d-flex gap-2">
    <input id="msgInput" class="form-control" placeholder="Nhập tin nhắn…" />
    <button id="sendBtn" type="button" class="btn btn-primary">Gửi</button>
  </form>
</div>

<script>
(function () {
  const ctx    = '${ctx}';
  const shopId = '${param.shopId}';               // /chat?shopId=...
  if (!shopId) { console.warn('Missing shopId'); return; }

  // Nick gửi kèm query (?nick=ROLE_Firstname)
  const nick = encodeURIComponent('${fn:escapeXml(nick)}');

  const wsUrl = (location.protocol === 'https:' ? 'wss://' : 'ws://')
              + location.host + ctx + '/ws/chat/' + shopId + '?nick=' + nick;

  const box   = document.getElementById('chatBox');
  const input = document.getElementById('msgInput');
  const btn   = document.getElementById('sendBtn');

  let ws;
  function append(line){
    const d = document.createElement('div');
    d.textContent = line;
    box.appendChild(d);
    box.scrollTop = box.scrollHeight;
  }
  function connect(){
    ws = new WebSocket(wsUrl);
    ws.onopen    = () => append('🔌 Đã kết nối.');
    ws.onmessage = (e) => append(e.data);
    ws.onclose   = () => append('❌ Mất kết nối.');
    ws.onerror   = () => append('⚠️ Lỗi kết nối.');
  }

  btn.addEventListener('click', () => {
    const t = (input.value || '').trim();
    if (!t || !ws || ws.readyState !== 1) return;
    ws.send(t);
    input.value = '';
  });
  input.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); btn.click(); }
  });

  connect();
})();
</script>
