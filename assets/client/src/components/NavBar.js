import React from 'react'
import { Flex, VStack, Heading, IconButton, Spacer,Stack, Button } from '@chakra-ui/react';
import { FaSun, FaMoon, FaGithub, FaLinkedin } from 'react-icons/fa';
import { SiUpwork } from 'react-icons/si'
import { useColorMode } from "@chakra-ui/color-mode"
const NavBar = () => {

    const { colorMode, toggleColorMode } = useColorMode();
    const isLight = colorMode === "light"

    return (
        <VStack p={5}>
            <Flex w="80%" alignItems="center">
                {/* <Image borderRadius='full' boxSize='55px' src="https://github.com/kptdaaron.png" /> */}
                <Heading size='xl' fontWeight='normal' fontFamily="Damion" variant="banner">jactrajano</Heading>
                <Spacer />
                <Stack direction="row" spacing={1}>

                    <Button backgroundColor="transparent" leftIcon={<SiUpwork />}>Upwork</Button>
                    <Button backgroundColor="transparent" leftIcon={<FaLinkedin />}>LinkedIn</Button>
                    <Button backgroundColor="transparent" leftIcon={<FaGithub />}>github</Button>
                </Stack>
                {/* <IconButton ml={2} backgroundColor="transparent" isRound="true" icon={<SiUpwork />} />
                <IconButton ml={2} backgroundColor="transparent" isRound="true" icon={<FaLinkedin />} />
                <IconButton ml={2} backgroundColor="transparent" isRound="true" icon={<FaGithub />} /> */}
                <IconButton ml={8} icon={isLight ? <FaMoon /> : <FaSun />} isRound="true" onClick={toggleColorMode} />

            </Flex>
        </VStack>
    )
}

export default NavBar