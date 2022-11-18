/*
 * JBoss, Home of Professional Open Source
 * Copyright 2015, Red Hat, Inc. and/or its affiliates, and individual
 * contributors by the @authors tag. See the copyright.txt in the
 * distribution for a full listing of individual contributors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.jboss.as.quickstarts.kitchensink_ear;

import org.jboss.as.quickstarts.kitchensink_ear.data.MemberRepositoryIF;
import org.jboss.as.quickstarts.kitchensink_ear.model.Member;

import javax.annotation.PostConstruct;
import javax.enterprise.context.RequestScoped;
import javax.enterprise.event.Observes;
import javax.enterprise.event.Reception;
import javax.enterprise.inject.Produces;
import javax.inject.Named;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.util.Hashtable;
import java.util.List;

@RequestScoped
public class MemberListProducer {

    private List<Member> members;

    // @Named provides access the return value via the EL variable name "members" in the UI (e.g.,
    // Facelets or JSP view)
    @Produces
    @Named
    public List<Member> getMembers() {
        return members;
    }

    public void onMemberListChanged(@Observes(notifyObserver = Reception.IF_EXISTS) final Member member) {
        retrieveAllMembersOrderedByName();
    }

    @PostConstruct
    public void retrieveAllMembersOrderedByName() {
        try {
            members = lookupMemberRepository().findAllOrderedByName();
        } catch (NamingException e) {
            e.printStackTrace();
        }
    }

    private MemberRepositoryIF lookupMemberRepository() throws NamingException {
        final Hashtable jndiProperties = new Hashtable();
        jndiProperties.put(Context.INITIAL_CONTEXT_FACTORY, "org.wildfly.naming.client.WildFlyInitialContextFactory");
        String backend_provider_url = System.getenv("BACKEND_PROVIDER_URL");
        jndiProperties.put(Context.PROVIDER_URL,backend_provider_url);
        Context context = new InitialContext(jndiProperties);
        return (MemberRepositoryIF) context.lookup("ejb:kitchensink-ear/kitchensink-ear-ejb/MemberRepository!org.jboss.as.quickstarts.kitchensink_ear.data.MemberRepositoryIF");
    }
}
