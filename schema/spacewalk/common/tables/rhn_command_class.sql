--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
--
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation.
--


CREATE TABLE rhn_command_class
(
    class_name  VARCHAR2(40) NOT NULL
                    CONSTRAINT rhn_comcl_class_name_pk PRIMARY KEY
                    USING INDEX TABLESPACE [[2m_tbs]]
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_command_class IS 'COMCL Command classes';

