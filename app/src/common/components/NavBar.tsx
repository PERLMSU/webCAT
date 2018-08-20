import * as React from "react";
import { Navbar, NavbarBrand, NavbarItem, NavbarMenu, NavbarStart } from "bloomer";

export const NavBar: React.SFC = () => <Navbar>
    <NavbarBrand>
        <NavbarItem>P3 WebCAT</NavbarItem>
    </NavbarBrand>
    <NavbarMenu>
        <NavbarStart>
            <NavbarItem href='#'>Users</NavbarItem>
            <NavbarItem href='#'>Classroom</NavbarItem>
            <NavbarItem href='#'>Inbox</NavbarItem>
            <NavbarItem href='#'>Categories</NavbarItem>
            <NavbarItem href='#'>Feedback</NavbarItem>
            <NavbarItem href='#'>Notes</NavbarItem>
            <NavbarItem href='#'>Writer</NavbarItem>
        </NavbarStart>
    </NavbarMenu>
</Navbar>
