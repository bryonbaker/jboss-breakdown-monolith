package org.jboss.as.quickstarts.kitchensink_ear.service;

import org.jboss.as.quickstarts.kitchensink_ear.model.Member;

public interface MemberRegistrationIF {
    void register(Member member) throws Exception;
}
