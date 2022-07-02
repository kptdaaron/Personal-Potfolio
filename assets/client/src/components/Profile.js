import React from 'react'
import { Flex, Heading, Spacer, Box } from '@chakra-ui/react';
import { Image } from "@chakra-ui/image"

const Profile = () => {
    return (
        <>
            <Box w="70%">
                <Flex p="5" alignItems="center">
                    <Box pr={5}>
                        <Image boxSize="80px" borderRadius="full" src="https://github.com/kptdaaron.png" alt="Aaron Trajano" />
                    </Box>
                    <Box>
                        <Flex pl={4}>

                            <Heading fontFamily="Fira Code" fontWeight="bold">A A R O N</Heading>
                            <Heading pl={4} fontFamily="Fira Code" fontWeight="medium" fontSize='4xl'>TRAJANO</Heading>
                        </Flex>

                        <Flex pl={4}>
                            <Heading pt={1} fontWeight="medium" fontSize="2xl">Fullstack Developer</Heading>
                            <Spacer />
                            {/* <Button backgroundColor="transparent" rightIcon={<FaDownload />}>Resume</Button>        */}
                        </Flex>
                    </Box>
                </Flex>
                <Box p="5">
                    <Box pt={2} fontWeight="sm">Lorem ipsum, dolor sit amet consectetur adipisicing elit. Earum, veritatis. Assumenda reiciendis obcaecati quibusdam aliquid ex possimus deserunt ipsam modi, adipisci doloremque, at non totam quas ad eum, ipsa ab provident laborum! Iste recusandae aliquid magnam? Illum suscipit excepturi assumenda voluptatibus, soluta impedit recusandae natus, veniam quod non ad ipsam?</Box>
                </Box>
            </Box>
        </>

    )
}

export default Profile