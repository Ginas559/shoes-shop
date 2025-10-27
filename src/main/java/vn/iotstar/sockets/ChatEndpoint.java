package vn.iotstar.sockets;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

/** 1 vendor = 1 room chat.
 *  ws://<host>/<context>/ws/chat/{shopId}?nick=ROLE_Firstname
 */
@ServerEndpoint("/ws/chat/{shopId}")
public class ChatEndpoint {

    // roomId -> set of sessions
    private static final Map<String, Set<Session>> ROOMS = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("shopId") String shopId) {
        ROOMS.computeIfAbsent(shopId, k -> ConcurrentHashMap.newKeySet()).add(session);

        // Lấy nick từ query (?nick=...) và cache vào userProperties
        String display = resolveNick(session);
        session.getUserProperties().put("nick", display);

        broadcast(shopId, "[JOIN] " + display + " đã tham gia phòng.");
    }

    @OnMessage
    public void onMessage(Session session, @PathParam("shopId") String shopId, String message) {
        broadcast(shopId, nick(session) + ": " + message);
    }

    @OnClose
    public void onClose(Session session, @PathParam("shopId") String shopId) {
        Set<Session> set = ROOMS.get(shopId);
        if (set != null) {
            set.remove(session);
            if (set.isEmpty()) ROOMS.remove(shopId);
        }
        broadcast(shopId, "[LEAVE] " + nick(session) + " đã rời phòng.");
    }

    private static void broadcast(String shopId, String payload) {
        Set<Session> set = ROOMS.get(shopId);
        if (set == null) return;
        for (Session s : set) {
            try { s.getBasicRemote().sendText(payload); } catch (IOException ignored) {}
        }
    }

    private static String nick(Session s) {
        Object n = s.getUserProperties().get("nick");
        return (n != null && !n.toString().isBlank()) ? n.toString() : resolveNick(s);
    }

    private static String resolveNick(Session s) {
        try {
            Map<String, java.util.List<String>> q = s.getRequestParameterMap();
            if (q != null) {
                var v = q.get("nick");
                if (v != null && !v.isEmpty()) {
                    String val = v.get(0);
                    if (val != null && !val.isBlank()) return val.trim();
                }
            }
        } catch (Exception ignore) {}

        try {
            if (s.getUserPrincipal() != null) return s.getUserPrincipal().getName();
        } catch (Exception ignore) {}

        return "guest_user"; // fallback cuối cùng
    }
}
