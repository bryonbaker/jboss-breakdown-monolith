package org.jboss.rbx.rbank;

import org.jboss.rbx.rbank.contact.data.MemberRepositoryIF;
import org.jboss.rbx.rbank.contact.model.Member;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.util.Hashtable;
import java.util.List;

public class BackendHealthCheck {

    private static final String MemberRepositoryIF_EJB_LOOKUP = "ejb:backend/ejb/MemberRepository!org.jboss.rbx.rbank.contact.data.MemberRepositoryIF";

    public static void main(String[] args) {
        
        try {
            List<Member> members = lookupMemberRepository().findAllOrderedByName();
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }


    public static MemberRepositoryIF lookupMemberRepository() throws NamingException {
        return (MemberRepositoryIF) getContext().lookup(MemberRepositoryIF_EJB_LOOKUP);
    }

    private static Context getContext() throws NamingException {
        final Hashtable<String, String> jndiProperties = new Hashtable<String, String>();
        jndiProperties.put(Context.INITIAL_CONTEXT_FACTORY, "org.wildfly.naming.client.WildFlyInitialContextFactory");
        String backend_provider_url = System.getenv("BACKEND_PROVIDER_URL");
        if (backend_provider_url == null || backend_provider_url.isEmpty()) {
            backend_provider_url = "remote+http://localhost:8080";
        }
        jndiProperties.put(Context.PROVIDER_URL,backend_provider_url);
        jndiProperties.put(Context.SECURITY_PRINCIPAL, "jboss");
        jndiProperties.put(Context.SECURITY_CREDENTIALS, "jboss");
        jndiProperties.put("jboss.naming.client.connect.options.org.xnio.Options.SASL_DISALLOWED_MECHANISMS", "JBOSS-LOCAL-USER");
        return new InitialContext(jndiProperties);
    }

}
