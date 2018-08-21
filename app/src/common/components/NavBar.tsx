import * as React from "react";
import { Navbar, NavbarBrand, NavbarItem, NavbarMenu, NavbarStart, NavbarLink, NavbarDropdown, NavbarDivider } from "bloomer";

export const NavBar: React.SFC = () => <Navbar>
    <NavbarBrand>
        <NavbarItem>P3 WebCAT</NavbarItem>
    </NavbarBrand>
    <NavbarMenu>
        <NavbarStart>
            <NavbarItem href='#'>Users</NavbarItem>
            <NavbarItem hasDropdown isHoverable>
                <NavbarLink href='#'>Rotations</NavbarLink>
                <NavbarDropdown>
                    <NavbarItem href='#'>Semesters</NavbarItem>
                    <NavbarItem href='#'>Students</NavbarItem>
                    <NavbarItem href='#'>Classrooms</NavbarItem>
                    <NavbarItem href='#'>Rotations</NavbarItem>
                    <NavbarItem href='#'>Rotation Groups</NavbarItem>
                </NavbarDropdown>
            </NavbarItem>
            <NavbarItem href='#'>Inbox</NavbarItem>
            <NavbarItem hasDropdown isHoverable>
                <NavbarLink href="#">Feedback</NavbarLink>
                <NavbarDropdown>
                    <NavbarLink href="#">Observations</NavbarLink>
                    <NavbarLink href="#">Writer</NavbarLink>
                    <NavbarDivider />
                    <NavbarLink href="#">Categories</NavbarLink>
                    <NavbarDivider />
                    <NavbarLink href="#">Drafts</NavbarLink>
                </NavbarDropdown>
            </NavbarItem>
        </NavbarStart>
    </NavbarMenu>
</Navbar>
