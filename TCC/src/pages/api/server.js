const express = require('express')
const jsforce = require ('jsforce')
const path = require('path');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config()

const app = express()
const PORT = 3001

app.use(cors());
app.use(bodyParser.json());
app.use(express.json());

const {SF_LOGIN_URL, SF_USERNAME, SF_PASSWORD, SF_TOKEN} = process.env
const conn = new jsforce.Connection({
    loginUrl: SF_LOGIN_URL

})

conn.login(SF_USERNAME, SF_PASSWORD+SF_TOKEN, (err, userInfo)=>{
    if(err){
        console.log(SF_USERNAME)
        console.error(err)
    } else {
        console.log('User Id: ' + userInfo.id)
        console.log('Org Id: ' + userInfo.organizationId)
    }
})


app.post('/api', (req, res)=>{
    console.log('Dados recebidos do formulário:', req.body.data);
    conn.apex.post("/createAlumniLead/", req.body.data, function(err, response) {
        if (err) { 
            //res.send(err)
            res.status(500).send({ success: false, error: err.message });
            return console.error(err);
        }
        console.log("response: ", response);
        res.status(200).send({ success: true, message: "Operação realizada com sucesso" });
    });

    // conn.query("SELECT Id, Name FROM User", (err, result)=>{
    //     if(err){
    //         res.send(err)
    //     } else {
    //         console.log('Total records: ' + result.totalSize)
    //         res.json(result.records)
    //     }
    // })
    //res.send("Salesforce integration with nodejs")
})

app.get('/api/contact', (req, res) => {
    const cpf = req.query.cpf; // Obtém o CPF da query string

    if (!cpf) {
        return res.status(400).send({ success: false, error: 'CPF is required' });
    }

    conn.apex.get(`/getContactByCPF/?cpf=${cpf}`, (err, response) => {
        if (err) {
            console.error(err);
            return res.status(500).send({ success: false, error: err.message });
        }

        if (response.error) {
            return res.status(404).send({ success: false, error: response.error });
        }

        res.status(200).send({ success: true, data: response });
    });
});


app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`)
})