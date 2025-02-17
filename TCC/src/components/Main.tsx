import { useState } from "react";

import Button from "./Button";
import Header from "./Header";
import IconText from "./IconText";
import Registration from "./Registration";
import Search from "./Search";

export default function Main() {
    const [contactData, setContactData] = useState(null); // Armazena os dados retornados

    const [isRegistering, setIsRegistering] = useState(false);

    const handleSearchResult = (data) => {
        setContactData(data);
        setIsRegistering(true);
    };

    return (
        <div>
            <div>
                <Header />
            </div>
            <div className='relative p-96 bg-center bg-cover bg-no-repeat' style={{ backgroundImage: `url(/images/alumni_background2.png)`, backgroundSize: '100% 100%'}}>
                <div className='absolute flex flex-col justify-center top-1 bottom-0 left-0 text-left'>
                    <div>
                        <span className='text-3xl ml-5 font-bold text-white drop-shadow-md bg-green-800/75 p-2'>
                            Estamos construindo o Portal de Egressos da UNIFESP
                        </span>
                    </div>
                    <div>
                        <h1 className='text-2xl ml-5 mt-10 font-bold text-emerald-800 drop-shadow-md p-2'>
                            Seu primeiro passo é se cadastrar na plataforma:
                        </h1>
                        <Button
                            type='button'
                            className='absolute left-48 bottom-15 px-4 py-2 rounded-xl m-9 bg-emerald-800 font-semibold text-white shadow-lg'
                            onClick={() => {
                                const searchElement = document.getElementById("search");
                                if (searchElement) {
                                const y = searchElement.getBoundingClientRect().top;
                                window.scrollTo({ top: y, behavior: 'smooth' });
                                }
                            }} 
                        >
                            Cadastre-se aqui!
                        </Button>
                    </div>
                </div>
            </div>
            <div>
                <div className="relative bg-white p-28">
                    <span className="absolute text-3xl font-bold text-green-800 top-6 right-0 bottom-0 left-5">
                        Futuras ferramentas e vantagens:
                    </span>
                    <div className='flex justify-center'>
                        <IconText icon="/images/icons/home.png" text="Tudo em um só lugar" />
                        <IconText icon="/images/icons/business.png" text="Oportunidades<br />de emprego" />
                        <IconText icon="/images/icons/book.png" text="Acesso à biblioteca" />
                        <IconText icon="/images/icons/calendar.png" text="Atualizações sobre<br />eventos e atividades" />
                        <IconText icon="/images/icons/people.png" text="Encontre colegas<br />de turma" />
                    </div>
                    <div className='absolute text-gray-400 text-center inset-x-0 bottom-12'>
                        E muito mais...
                    </div>
                </div>
            </div>

            {isRegistering ? (
                <div id="registration">
                    <Registration contactData={contactData} />
                </div>
            ) : (
                <div id="search">
                    <Search onSearchComplete={handleSearchResult} />
                </div>
            )}

        </div>
    )
}