package org.jboss.rbx.rbank.contact.service;

import org.jboss.rbx.rbank.contact.model.Member;

public interface MemberRegistrationIF {
    void register(Member member) throws Exception;
}
