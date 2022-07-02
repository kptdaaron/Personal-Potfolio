import React from 'react'
import { Flex, VStack, Heading, IconButton, Spacer, Link, Button, Text, Box } from '@chakra-ui/react';


const Social = () => {
    return (
        <>
            <Box m={2} ml={5} w="100%">
                <Box m={1} p={5} border="1px">
                    <Heading>
                        Github Repo.
                    </Heading>
                </Box>
                <Box m={1} p={5} border="1px">
                    <Heading>
                        Projects
                    </Heading>
                </Box>
                <Box m={1} p={5} border="1px">
                    <Heading>
                        Blog
                    </Heading>
                </Box>
            </Box >
        </>

    )
}

export default Social