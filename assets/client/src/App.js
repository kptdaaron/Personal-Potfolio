import { Flex, VStack, Heading, IconButton, Spacer, Link, Button, Text, HStack, Box, Container } from '@chakra-ui/react';
import NavBar from "./components/NavBar"
import Profile from "./components/Profile";
import Social from "./components/Social";

function App() {

  return (
    <>
      <NavBar />
      <VStack p={5}>
        <Flex w="80%">
          <Profile />
          <Social />
        </Flex>
      </VStack>
    </>
  );
}

export default App;
