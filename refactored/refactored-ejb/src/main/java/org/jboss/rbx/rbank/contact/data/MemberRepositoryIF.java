package org.jboss.rbx.rbank.contact.data;

import org.jboss.rbx.rbank.contact.model.Member;

import java.util.List;

public interface MemberRepositoryIF {
    Member findById(Long id);

    Member findByEmail(String email);

    List<Member> findAllOrderedByName();
}
