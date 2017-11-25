package servlets;

import com.jcraft.jsch.JSch;
import com.jcraft.jsch.Session;
import sftputils.SftpUtils;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.Properties;
import java.util.stream.Collectors;

import static java.util.stream.Collectors.*;
import static javax.servlet.http.HttpServletResponse.SC_BAD_REQUEST;
import static sftputils.SftpUtils.execute;

@WebServlet("/images/*")
public class ImagesServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        String pathInfo = req.getPathInfo();

        if (pathInfo == null){
            resp.getWriter().write("parameter file required");
            resp.setStatus(SC_BAD_REQUEST);
        }

        String fileName = pathInfo.substring(1);

        Session session = createSession();

        byte[] bytes = execute(session, channel -> {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            System.out.println("downloading: " + fileName);
            channel.get(fileName, baos);
            return baos.toByteArray();
        });

        session.disconnect();
        resp.getOutputStream().write(bytes);
    }

    private Session createSession(){
        try {
            JSch jsch = new JSch();
            Session session = jsch.getSession("mhewedy", "localhost", 22);
            Properties config = new Properties();
            config.setProperty("StrictHostKeyChecking", "no");
            session.setConfig(config);
            session.setPassword("system");
            session.connect();
            return session;
        }catch (Exception ex){
            throw new RuntimeException(ex);
        }
    }
}
