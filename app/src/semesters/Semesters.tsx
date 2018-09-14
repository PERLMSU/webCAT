import * as React from "react";
import {Title, Box, Hero, HeroBody, Column, Subtitle, Container } from 'bloomer';



export default class Semesters extends React.Component {
    public render() {
        return (
            <Hero isColor="primary" isFullHeight>
                <HeroBody>
                    <Container hasTextAlign="centered">
                        <Column isSize="1/2" isOffset="1/4">
                            <Box>
                                <Title>Semesters</Title>
                                <Subtitle>Semestersdadas REEEE</Subtitle>
                            </Box>
                        </Column>
                    </Container>
                </HeroBody>
            </Hero>
        );
    }
}
