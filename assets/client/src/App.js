import './App.css';
import { FaAws, FaDocker, FaJenkins } from 'react-icons/fa';
import { SiTerraform, SiAnsible } from 'react-icons/si';


function App() {
  return (
    <div className="App">
      <header className="App-header">
        <p>
        <h1>This site is under development</h1>
        </p>
        <div>
          <h3>Powered by:</h3>
          <FaAws size={80}/> <SiTerraform size={80}/> <SiAnsible size={80}/> <FaDocker size={80}/> <FaJenkins size={80}/>
        </div>
        
      </header>
    </div>
  );
}

export default App;
