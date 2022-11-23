package org.jboss.as.quickstarts.kitchensink_ear.data;

import org.jboss.as.quickstarts.kitchensink_ear.model.Member;

import java.util.List;

public interface MemberRepositoryIF {
    Member findById(Long id);

    Member findByEmail(String email);

    List<Member> findAllOrderedByName();
}
